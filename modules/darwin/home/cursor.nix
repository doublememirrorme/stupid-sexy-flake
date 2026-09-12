{ pkgs, ... }:
let
  shared = import ./editor-settings.nix pkgs;
in
{
  # Cursor is the Homebrew cask in /Applications and auto-updates outside Nix.
  # programs.cursor only writes ~/Library/Application Support/Cursor/User/settings.json
  # and ~/.cursor/extensions.
  programs.cursor = {
    enable = true;
    package = null;

    mutableExtensionsDir = false;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions = shared.extensions;

      userSettings = shared.userSettings;
    };
  };
}
