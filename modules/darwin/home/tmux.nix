{ config, pkgs, ... }:
let
  palette = import ./tinacious-palette.nix;

  # Only the pane borders actually differ between the two. statusBar.background
  # is the same pink in both Tinacious variants, so the bar itself never changes.
  mkTheme = variant: ''
    set -g status-style "bg=${palette.pink},fg=${palette.white}"
    set -g status-left-style "bg=${palette.pink},fg=${palette.white},bold"
    set -g status-right-style "bg=${palette.pink},fg=${palette.white}"

    set -g window-status-style "bg=${palette.pink},fg=${palette.white}"
    set -g window-status-current-style "bg=${palette.pinkDeep},fg=${palette.white},bold"
    set -g window-status-activity-style "bg=${palette.purple},fg=${palette.white}"
    set -g window-status-bell-style "bg=${palette.purple},fg=${palette.white},bold"

    set -g message-style "bg=${palette.pinkDeep},fg=${palette.white}"
    set -g message-command-style "bg=${palette.pinkDeep},fg=${palette.white}"
    set -g mode-style "bg=${palette.pink},fg=${palette.white}"

    set -g pane-border-style "fg=${variant.border}"
    set -g pane-active-border-style "fg=${palette.pink}"
    set -g display-panes-colour "${variant.border}"
    set -g display-panes-active-colour "${palette.pink}"

    set -g clock-mode-colour "${palette.pink}"
  '';
in
{
  xdg.configFile."tmux/theme-dark.conf".text = mkTheme palette.dark;
  xdg.configFile."tmux/theme-light.conf".text = mkTheme palette.light;

  programs.tmux = {
    enable = true;

    sensibleOnTop = true;
    keyMode = "vi";
    customPaneNavigationAndResize = true;

    baseIndex = 1;
    mouse = true;
    focusEvents = true;
    disableConfirmationPrompt = true;
    historyLimit = 50000;
    terminal = "tmux-256color";
    shell = "${pkgs.zsh}/bin/zsh";

    plugins = [
      pkgs.tmuxPlugins.yank
    ];

    extraConfig = ''
      set -g status-position top
      set -g renumber-windows on
      set -g set-titles on
      set -g set-titles-string "#T"

      # Tinacious Design, the same palette as the VS Code theme. Pick the variant
      # matching the system appearance at startup; the dark-mode-notify agent in
      # appearance.nix re-sources it whenever the appearance changes after that.
      if-shell '[ "$(/usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null)" = "Dark" ]' \
        'source-file ${config.xdg.configHome}/tmux/theme-dark.conf' \
        'source-file ${config.xdg.configHome}/tmux/theme-light.conf'

      # Manual re-sync, for when you want it without waiting on the agent.
      bind-key T run-shell tmux-theme
    '';
  };
}
