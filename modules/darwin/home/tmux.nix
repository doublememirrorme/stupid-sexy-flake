{ config, pkgs, ... }:
{
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
    '';
  };
}
