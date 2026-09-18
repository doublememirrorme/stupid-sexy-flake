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

    # Leave the answer on disk for anything that cannot ask the terminal
    # again. Vim queries OSC 11 once at startup and never re-queries, so a
    # running vim reads this file on FocusGained to notice a flip. Written
    # before the tmux check below, since vim wants it whether tmux is up or
    # not. The directory is created first, XDG_STATE_HOME may not exist yet
    # on a fresh boot.
    mkdir -p "${config.xdg.stateHome}"
    printf '%s\n' "$variant" > "${config.xdg.stateHome}/appearance"

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
