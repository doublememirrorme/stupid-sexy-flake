{ pkgs, config, ... }:
let
  primaryUser = config.system.primaryUser;
in
{
  fonts.packages = with pkgs; [
    dejavu_fonts
    noto-fonts
  ];

  # GTK apps (e.g. nicotine-plus) use Pango/fontconfig, which macOS does not
  # provide out of the box. Without this, Pango fails to load a fallback font.
  environment.variables = {
    FONTCONFIG_FILE = "${pkgs.makeFontsConf {
      fontDirectories = config.fonts.packages ++ [
        "/Library/Fonts/Nix Fonts"
        "/Library/Fonts"
        "/System/Library/Fonts"
        "${config.users.users.${primaryUser}.home}/Library/Fonts"
      ];
    }}";

    # GTK 4 GPU rendering is unstable on macOS (search UI crashes, trace traps).
    GSK_RENDERER = "cairo";
  };
}
