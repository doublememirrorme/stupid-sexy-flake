{ config, ... }:
{
  programs.nushell = {
    enable = true;

    environmentVariables = {
      XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
      DOCKER_CONFIG = "${config.home.homeDirectory}/.config/docker";
      NVM_DIR = "${config.xdg.configHome}/nvm";
    };

    extraConfig = ''
      $env.config = ($env.config | default {} | merge {
        show_banner: false
      })

      def beet-table [format: string, ...query: string] {
        beet ls ...$query -f $format
        | lines
        | split column " | " ...($format | split row " | ")
      }

      def beet-dup-table [] {
        beet dup -a -F -f '$albumartist | $album | $path | $albumtotal'
        | lines
        | split column " | " artist album path tracks
      }

      def beet-orphans [--partial] {
        if $partial {
          ^beet-orphans --partial
        } else {
          ^beet-orphans
        }
      }
    '';
  };
}
