{ lib, ... }:
let
  palette = import ./tinacious-palette.nix;
  colour = palette.toITerm;

  # iTerm2 3.5+ keeps two colour sets per profile and follows the system
  # appearance itself, so this needs no daemon. Key names and the " (Light)" /
  # " (Dark)" suffixes are iTerm's own.
  colourSet = variant: suffix:
    let
      named = {
        "Foreground Color" = variant.foreground;
        "Background Color" = variant.background;
        "Bold Color" = variant.foreground;

        "Cursor Color" = variant.cursor;
        "Cursor Text Color" = variant.background;

        "Selection Color" = variant.selection;
        "Selected Text Color" = variant.foreground;

        "Link Color" = palette.cyan;
        "Badge Color" = palette.pinkDeep;
        "Cursor Guide Color" = variant.selection;

        # Tab colour. In the Minimal theme it also paints the title bar when
        # the tab bar is hidden, so it matches the tmux and VS Code status bars.
        "Tab Color" = palette.pink;
      };
      ansi = lib.listToAttrs (
        lib.imap0 (i: hex: lib.nameValuePair "Ansi ${toString i} Color" hex) variant.ansi
      );
    in
    lib.mapAttrs' (k: hex: lib.nameValuePair "${k} ${suffix}" (colour hex)) (named // ansi);

  # A dynamic profile: iTerm2 reads this folder on launch and on every change,
  # so there is nothing to import by hand. Anything not named here comes from
  # the parent profile. iTerm2 strips "Default Bookmark" from dynamic profiles
  # (issue 4115), so the default is set with "Default Bookmark Guid" below.
  tinaciousProfile = {
    Name = "Tinacious Design";
    Guid = "tinacious-design";
    # Pinned by name: once this profile is the default, an unset parent would
    # be itself, and the old settings (spacing, command) would stop carrying over.
    "Dynamic Profile Parent Name" = "Default";

    # FiraCode Nerd Font Mono: FiraCode ligatures plus single-cell Nerd Font
    # icons for yazi, at the size the old Fira Mono profile used.
    "Normal Font" = "FiraCodeNFM-Reg 15";
    "Use Non-ASCII Font" = false;
    "ASCII Ligatures" = true;
    # iTerm2 draws powerline shapes itself, sized to the cell. The font's own
    # glyphs ignore the 1.31 line spacing, so yazi's rounded caps stuck out
    # above and below its bars.
    "Draw Powerline Glyphs" = true;

    "Use Separate Colors for Light and Dark Mode" = true;
    # With separate light/dark colours on, iTerm2 reads the suffixed keys and
    # only falls back to "Use Tab Color" when they are missing. The parent
    # "Default" profile sets both to false, so they must be set here.
    "Use Tab Color (Light)" = true;
    "Use Tab Color (Dark)" = true;
    "Use Cursor Guide" = false;
  }
  // colourSet palette.light "(Light)"
  // colourSet palette.dark "(Dark)";
in
{
  targets.darwin.defaults."com.googlecode.iterm2" = {
    PromptOnQuit = false;
    CopySelection = true;
    AddNewTabAtEndOfTabs = true;
    TabStyleWithAutomaticOption = 5;
    # iTerm2 reads this once at launch, so quit and reopen it after a switch.
    "Default Bookmark Guid" = "tinacious-design";

    # Advanced setting "Use P3 as default color space?", on by default. With it
    # on, colours apps send (yazi's pink bars) are painted as Display P3, but
    # iTerm2 tints its own powerline caps inside a plain device RGB bitmap, so
    # the same pink comes out flatter on the caps and the two do not match.
    # The profile palette is stored as sRGB and is not affected either way.
    # Also read once at launch.
    P3 = false;
  };

  home.file."Library/Application Support/iTerm2/DynamicProfiles/tinacious-design.json".text =
    builtins.toJSON { Profiles = [ tinaciousProfile ]; };
}
