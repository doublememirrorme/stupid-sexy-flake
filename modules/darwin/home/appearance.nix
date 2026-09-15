{ config, pkgs, ... }:
let
  tmuxBin = "${config.programs.tmux.package}/bin/tmux";

  # dark-mode-notify runs this once at load and again on every appearance change,
  # with DARKMODE=1 for dark and DARKMODE=0 for light. Falling back to `defaults`
  # keeps it usable by hand, which is what the tmux prefix+T binding does.
  tmuxTheme = pkgs.writeShellScriptBin "tmux-theme" ''
    if [ -n "''${DARKMODE:-}" ]; then
      [ "$DARKMODE" = "1" ] && variant=dark || variant=light
    elif [ "$(/usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null)" = "Dark" ]; then
      variant=dark
    else
      variant=light
    fi

    # No server running means nothing to restyle, and that is not an error.
    ${tmuxBin} has-session 2>/dev/null || exit 0

    ${tmuxBin} source-file "${config.xdg.configHome}/tmux/theme-$variant.conf"
  '';
in
{
  home.packages = [ pkgs.dark-mode-notify tmuxTheme ];

  launchd.agents.dark-mode-notify = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.dark-mode-notify}/bin/dark-mode-notify"
        "${tmuxTheme}/bin/tmux-theme"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/dark-mode-notify.log";
    };
  };
}
