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

    # Syntax colours for a true-colour editor, keyed by what the text is
    # rather than by hue. See light.text below for why this set exists at
    # all. Ratios are WCAG contrast against this variant's own background,
    # #1D1D26. The dark theme upstream is already fine, so these are the
    # upstream values unchanged.
    text = {
      normal = foreground;      # #B3B3D4, 8.21:1
      statement = pink;         # #FF3399, 4.92:1
      type = blue;              # #00BFFF, 7.88:1
      function = green;         # #00D364, 8.36:1
      string = yellow;          # #FFCC66, 11.21:1
      constant = purple;        # #CC66FF, 5.50:1
      special = cyan;           # #00CED1, 8.56:1
      parameter = yellow;       # #FFCC66, drawn italic
      # 3.13:1, under the 4.5 bar. Kept at the upstream value: dark mode is
      # the one the user is already happy with, and a brighter comment would
      # start competing with the code around it.
      comment = "#686889";
      lineNr = "#686889";       # UI chrome, not body text

      cursorLine = "#2c2c3e";   # editor.lineHighlightBackground
      pmenu = "#2a2a38";
      pmenuSel = "#3d3d56";
      visual = "#4a213d";       # a pink-leaning wash, so it reads as selected

      # The completion menu's kind and detail columns. Same reasoning as
      # light.text below: the menu grounds are #2a2a38 and #3d3d56, both
      # lighter than the editor's #1D1D26, so a colour tuned against the
      # editor loses contrast on them. The comment grey was the bad one,
      # #686889 measured 2.64:1 on the menu and 1.96:1 on the selected row.
      # Both values below are tuned against the selected row, the lighter of
      # the two grounds, so they clear on the plain row as well.
      menuKind = blue;          # #00BFFF, 4.95:1 selected, 6.66:1 plain
      menuExtra = "#aaaabe";    # 4.60:1 selected, 6.19:1 plain
    };
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

    # Syntax colours for a true-colour editor. The ansi list above is a
    # terminal palette: its slots were picked for coloured blocks, prompts
    # and badges, not for running text on #f8f8ff. Measured as text on that
    # background the upstream light accents land between 1.81:1 and 3.21:1,
    # so vim's built-in light scheme, which resolves Type, Constant, Comment
    # and friends to those very slots, washes out. Copying the upstream light
    # VS Code theme would not help either, it measures the same 1.81 to 3.21.
    # So each hue keeps its hue and saturation and drops lightness until it
    # clears 4.5:1. Ratios below are WCAG against #f8f8ff.
    text = {
      normal = foreground;      # #44425e, 9.08:1
      statement = pinkDeep;     # #b12350, was #FF3399 at 3.21:1, now 6.16:1
      type = "#017ba4";         # was #00AEE8 at 2.42:1, now 4.54:1
      function = "#00843e";     # was #00b253 at 2.65:1, now 4.55:1
      string = "#9c6800";       # was #FFAA00 at 1.81:1, now 4.52:1
      constant = "#9b3fd1";     # was #CC66FF at 2.87:1, now 4.93:1. As yazi and lazygit.
      special = "#007a7c";      # was #00CED1 at 1.85:1, now 4.87:1. As yazi.
      parameter = "#a06600";    # was #f49b00 at 2.08:1, now 4.52:1. Drawn italic.
      comment = "#756e91";      # was #A09BB3 at 2.54:1, now 4.52:1
      lineNr = "#7c79ac";       # UI chrome, not body text

      cursorLine = "#eae9ff";
      pmenu = "#eae9ff";
      pmenuSel = "#dbdaff";
      visual = selection;       # #dbdaff, editor.selectionBackground

      # The completion menu's kind and detail columns. They need their own
      # colours because they do not sit on the editor background: the menu
      # grounds are #eae9ff and #dbdaff, darker than #f8f8ff, so the body
      # colours above lose about half a point of contrast there. Reusing
      # type at #017ba4 gave 4.03:1 on the menu and 3.54:1 on the selected
      # row, and comment at #756e91 gave 4.00:1 and 3.52:1. Each of these is
      # tuned against the selected row, the darker of the two grounds, so it
      # clears on the plain row as well.
      menuKind = "#01688b";     # 4.62:1 selected, 5.25:1 plain
      menuExtra = "#625c7a";    # 4.65:1 selected, 5.28:1 plain
    };
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
