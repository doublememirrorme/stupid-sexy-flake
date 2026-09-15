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

        # The tab bar is iTerm's closest match to the VS Code status bar.
        "Tab Color" = palette.pink;
      };
      ansi = lib.listToAttrs (
        lib.imap0 (i: hex: lib.nameValuePair "Ansi ${toString i} Color" hex) variant.ansi
      );
    in
    lib.mapAttrs' (k: hex: lib.nameValuePair "${k} ${suffix}" (colour hex)) (named // ansi);

  # A dynamic profile: iTerm2 reads this folder on launch, so there is nothing
  # to import by hand. Anything not named here falls back to the default profile.
  tinaciousProfile = {
    Name = "Tinacious Design";
    Guid = "tinacious-design";
    "Default Bookmark" = "Yes";

    "Use Separate Colors for Light and Dark Mode" = true;
    "Use Tab Color" = true;
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
  };

  home.file."Library/Application Support/iTerm2/DynamicProfiles/tinacious-design.json".text =
    builtins.toJSON { Profiles = [ tinaciousProfile ]; };
}
