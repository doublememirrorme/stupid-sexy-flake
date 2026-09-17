{ config, pkgs, ... }:
let
  palette = import ./tinacious-palette.nix;
  yamlFormat = pkgs.formats.yaml { };
  cfgDir = "${config.xdg.configHome}/lazygit";

  # Same idea as yazi.nix: the palette's light accents are too faint as text
  # on #f8f8ff, so light mode uses darker shades of the same hues. Dark mode
  # keeps the palette as it is.
  lightText = palette.light // {
    purple = "#9b3fd1";       # was palette.purple #CC66FF
    pink = palette.pinkDeep;  # was palette.pink #ff3399, for text and titles
  };
  darkText = palette.dark // { inherit (palette) purple pink; };

  # lazygit only sets the background of the selected row, the text keeps its
  # own colours, so the row uses each variant's selection colour rather than
  # a pink badge. Panel titles are drawn in the border colour, which is why
  # the inactive border stays "default" (terminal foreground) and not the
  # faint palette border tmux uses.
  mkTheme = variant: {
    gui.theme = {
      activeBorderColor = [ variant.pink "bold" ];
      inactiveBorderColor = [ "default" ];
      searchingActiveBorderColor = [ variant.purple "bold" ];
      optionsTextColor = [ variant.purple ];
      selectedLineBgColor = [ variant.selection ];
      cherryPickedCommitFgColor = [ palette.white ];
      cherryPickedCommitBgColor = [ palette.purple ];
      markedBaseCommitFgColor = [ palette.white ];
      markedBaseCommitBgColor = [ palette.pinkDeep ];
      unstagedChangesColor = [ variant.pink ];
    };
  };

  # lazygit has no light/dark switch and reads its config once at startup.
  # LG_CONFIG_FILE takes a comma separated list that is merged in order, so
  # the wrapper stacks the variant matching the system appearance on top of
  # the base config, the same check tmux.nix does at startup. A preset
  # LG_CONFIG_FILE is left alone, which is handy for trying the other variant.
  lazygitWrapped = pkgs.writeShellScriptBin "lazygit" ''
    if [ -z "''${LG_CONFIG_FILE:-}" ]; then
      if [ "$(/usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null)" = "Dark" ]; then
        variant=dark
      else
        variant=light
      fi
      export LG_CONFIG_FILE="${cfgDir}/config.yml,${cfgDir}/theme-$variant.yml"
    fi
    exec ${pkgs.lazygit}/bin/lazygit "$@"
  '';
in
{
  xdg.configFile."lazygit/theme-dark.yml".source =
    yamlFormat.generate "lazygit-theme-dark.yml" (mkTheme darkText);
  xdg.configFile."lazygit/theme-light.yml".source =
    yamlFormat.generate "lazygit-theme-light.yml" (mkTheme lightText);

  programs.lazygit = {
    enable = true;
    # The nixpkgs package is just bin/lazygit, so the wrapper drops nothing.
    package = lazygitWrapped;

    # No lg shell function for now; plain `lazygit` is enough to try it.
    enableZshIntegration = false;
    enableNushellIntegration = false;

    # Written to ~/.config/lazygit/config.yml (xdg.enable is on in zsh.nix).
    # Mouse is already on by default. Keep this non-empty: home-manager skips
    # config.yml when settings is {}, and lazygit refuses to start when a file
    # the wrapper lists in LG_CONFIG_FILE is missing.
    settings = {
      gui.nerdFontsVersion = "3";
      update.method = "never";
      disableStartupPopups = true;
    };
  };
}
