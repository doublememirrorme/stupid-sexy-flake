{ pkgs, ... }:
let
  shared = import ./editor-settings.nix pkgs;
in
{
  # VS Code is the Homebrew cask and auto-updates outside Nix, same as Cursor.
  # programs.vscode only writes ~/Library/Application Support/Code/User/settings.json
  # and ~/.vscode/extensions.
  programs.vscode = {
    enable = true;
    package = null;

    mutableExtensionsDir = false;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      # VS Code-only. Cursor keeps its own extension set.
      extensions = shared.extensions ++ [ pkgs.vscode-extensions.anthropic.claude-code ];

      userSettings = shared.userSettings // {
        # "Cursor Dark Midnight" is a Cursor built-in; VS Code would silently fall back.
        "workbench.preferredDarkColorTheme" = "Default Dark Modern";
        "workbench.startupEditor" = "none";
      };
    };
  };
}
