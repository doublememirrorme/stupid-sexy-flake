{ config, lib, pkgs, ... }:
{
  xdg.enable = true;

  programs.zsh = {
    enable = true;
    dotDir = "${config.home.homeDirectory}/.config/zsh";

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 100000;
      save = 100000;
      extended = true;
    };

    sessionVariables = {
      XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
      DOCKER_CONFIG = "${config.home.homeDirectory}/.config/docker";
      ZSHZ_DATA = "${config.home.homeDirectory}/.config/zsh/.z";
      NVM_DIR = "${config.xdg.configHome}/nvm";
    };

    # Empty theme: Oh My Zsh must not set a theme so Pure can own the prompt (see Pure readme).
    "oh-my-zsh" = {
      enable = true;
      package = pkgs.oh-my-zsh;
      theme = "";
      plugins = [
        "git"
        "brew"
        "common-aliases"
        "node"
        "npm"
        "rand-quote"
        "sudo"
        "yarn"
        "z"
        "colored-man-pages"
        "colorize"
        "cp"
      ];
    };

    initContent = lib.mkMerge [
      # Before Pure (~850): nvm expects NVM_DIR (sessionVariables / profile).
      (lib.mkOrder 300 ''
        [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
      '')
      # After oh-my-zsh.sh (~800). Prepend Pure: first fpath match wins; brew site-functions may hold broken pure symlinks.
      (lib.mkOrder 850 ''
        fpath=(${pkgs.pure-prompt}/share/zsh/site-functions $fpath)
        autoload -U promptinit; promptinit
        prompt pure
      '')
    ];
  };
}
