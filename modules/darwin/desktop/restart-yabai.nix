{ pkgs, ... }:
let
  restartScript = services: pkgs.writeShellScriptBin services.name (
    ''
      set -euo pipefail

      uid=$(id -u)
      domain="gui/$uid"

      restart_service() {
        local label="$1"
        local plist="$HOME/Library/LaunchAgents/$label.plist"

        if [[ ! -f "$plist" ]]; then
          echo "error: $plist not found (run darwin-rebuild switch?)" >&2
          return 1
        fi

        launchctl bootout "$domain" "$plist" 2>/dev/null || true
        launchctl bootstrap "$domain" "$plist"
      }

      check_service() {
        local label="$1"
        local name="''${label##*.}"

        if pgrep -x "$name" >/dev/null; then
          echo "$label: running"
          return 0
        fi

        exit_code=$(launchctl print "$domain/$label" 2>/dev/null | sed -n 's/.*last exit code = \(.*\)/\1/p' || true)
        echo "$label: not running (exit: ''${exit_code:-unknown})" >&2

        bin=$(launchctl print "$domain/$label" 2>/dev/null | sed -n 's/^[[:space:]]*program = \(.*\)/\1/p' || true)
        if [[ -n "$bin" ]]; then
          echo "  grant Accessibility to: $bin" >&2
        fi

        return 1
      }

    ''
    + lib.concatMapStringsSep "\n" (label: ''
      pkill -x "${lib.removePrefix "org.nixos." label}" 2>/dev/null || true
    '') services.labels
    + ''

      sleep 0.5

    ''
    + lib.concatMapStringsSep "\n" (label: ''
      restart_service ${label}
    '') services.labels
    + ''

      sleep 1

      failed=0
    ''
    + lib.concatMapStringsSep "\n" (label: ''
      check_service ${label} || failed=1
    '') services.labels
    + ''

      exit "$failed"
    ''
  );

  lib = pkgs.lib;
in
{
  environment.systemPackages = [
    (restartScript {
      name = "restart-yabai";
      labels = [ "org.nixos.yabai" "org.nixos.skhd" ];
    })
    (restartScript {
      name = "restart-skhd";
      labels = [ "org.nixos.skhd" ];
    })
  ];
}
