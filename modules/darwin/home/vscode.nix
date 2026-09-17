{ pkgs, ... }:
let
  shared = import ./editor-settings.nix pkgs;
in
{
  # VS Code is the Homebrew cask and auto-updates outside Nix.
  # programs.vscode only writes ~/Library/Application Support/Code/User/settings.json
  # and ~/.vscode/extensions.
  programs.vscode = {
    enable = true;
    package = null;

    mutableExtensionsDir = false;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions = shared.extensions ++ [ pkgs.vscode-extensions.anthropic.claude-code ];

      userSettings = shared.userSettings // {
        "workbench.startupEditor" = "none";
      };
    };
  };
}
