# Tinacious Design colours, lifted from both VS Code theme files shipped by
# tinaciousdesign.theme-tinaciousdesign (see editor-settings.nix). VS Code follows
# the system appearance via window.autoDetectColorScheme, so the terminal carries
# both variants too and switches with it.
#
# Note: the light theme maps ANSI white to #ffffff, which is near invisible on its
# own #f8f8ff background. That is the theme's own choice and VS Code's built-in
# terminal has the same quirk. Change light.ansiWhite below if it ever bites.
let
  hexValue = c: {
    "0" = 0; "1" = 1; "2" = 2; "3" = 3; "4" = 4; "5" = 5; "6" = 6; "7" = 7;
    "8" = 8; "9" = 9;
    "a" = 10; "b" = 11; "c" = 12; "d" = 13; "e" = 14; "f" = 15;
    "A" = 10; "B" = 11; "C" = 12; "D" = 13; "E" = 14; "F" = 15;
  }.${c};

  channel = hex: offset:
    (hexValue (builtins.substring offset 1 hex) * 16
      + hexValue (builtins.substring (offset + 1) 1 hex)) / 255.0;

  # Shared by both variants. statusBar.background is the same pink either way,
  # which is why the tmux bar does not actually need to change colour.
  pink = "#ff3399";        # statusBar.background
  pinkDeep = "#b12350";    # statusBar.debuggingBackground, minus its alpha
  white = "#ffffff";       # statusBar.foreground
  purple = "#CC66FF";      # terminal.ansiMagenta
  cyan = "#00CED1";        # terminal.ansiCyan
  ansiBlack = "#2c2c3e";   # terminal.ansiBlack
  ansiBrightBlack = "#3d3d56";

  mkAnsi = { green, yellow, blue }: [
    ansiBlack       pink  green  yellow  blue  purple  cyan  white
    ansiBrightBlack pink  green  yellow  blue  purple  cyan  white
  ];
in
{
  inherit pink pinkDeep white purple cyan;

  dark = rec {
    background = "#1D1D26";     # editor.background / terminal.background
    foreground = "#B3B3D4";     # editor.foreground / terminal.foreground
    cursor = pink;              # editorCursor.foreground
    selection = "#2c2c3e";      # editor.lineHighlightBackground
    border = ansiBrightBlack;   # subtle enough on a dark ground

    green = "#00D364";
    yellow = "#FFCC66";
    blue = "#00BFFF";

    ansi = mkAnsi { inherit green yellow blue; };
  };

  light = rec {
    background = "#f8f8ff";     # editor.background
    foreground = "#44425e";     # editor.foreground
    cursor = pink;              # editorCursor.foreground
    selection = "#dbdaff";      # editor.selectionBackground
    border = "#dbdaff";         # editorIndentGuide.background

    green = "#00b253";
    yellow = "#FFAA00";
    blue = "#01a9e1";

    ansi = mkAnsi { inherit green yellow blue; };
  };

  # iTerm2 dynamic profiles want floats per channel, not hex.
  toITerm = hexWithHash:
    let hex = builtins.substring 1 6 hexWithHash;
    in {
      "Color Space" = "sRGB";
      "Red Component" = channel hex 0;
      "Green Component" = channel hex 2;
      "Blue Component" = channel hex 4;
      "Alpha Component" = 1;
    };
}
