{ pkgs, ... }:
{
  # Cursor diverged from VS Code: use pname = "cursor" so HM writes to ~/.cursor
  # and ~/Library/Application Support/Cursor/User instead of VS Code paths.
  # The app itself stays in /Applications and auto-updates outside Nix.
  programs.vscode = {
    enable = true;
    package = null;
    pname = "cursor";

    mutableExtensionsDir = false;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions = with pkgs.vscode-extensions; [
        dbaeumer.vscode-eslint
        eamodio.gitlens
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-containers
        vscodevim.vim
        jnoortheen.nix-ide
        github.vscode-pull-request-github
      ];

      userSettings = {
        files.autoSave = "onFocusChange";
        editor.fontFamily = "Fira Code, Menlo, Monaco, 'Courier New', monospace";
        editor.fontLigatures = true;
        editor.wordWrap = "wordWrapColumn";
        editor.tabSize = 2;
        editor.insertSpaces = true;
        editor.suggestSelection = "first";
        "javascript.updateImportsOnFileMove.enabled" = "always";
        "typescript.updateImportsOnFileMove.enabled" = "always";
        editor.formatOnSave = false;
        "editor.bracketPairColorization.enabled" = true;
        "editor.guides.bracketPairs" = "active";
        editor.codeActionsOnSave = {
          "source.fixAll" = "explicit";
        };
        "[json]".editor.defaultFormatter = "vscode.json-language-features";
        "[html]".editor.defaultFormatter = "esbenp.prettier-vscode";
        "[javascript]".editor.defaultFormatter = "esbenp.prettier-vscode";
        "[typescriptreact]".editor.defaultFormatter = "esbenp.prettier-vscode";
        "[javascriptreact]".editor.defaultFormatter = "esbenp.prettier-vscode";
        "[css]".editor.defaultFormatter = "esbenp.prettier-vscode";
        "[markdown]".editor.defaultFormatter = "esbenp.prettier-vscode";
        "workbench.iconTheme" = "city-lights-icons-vsc-light";
        git.autofetch = true;
        editor.minimap.enabled = false;
        "workbench.preferredHighContrastColorTheme" = "Tinacious Design (High Contrast)";
        "files.associations" = {
          "*.sass" = "scss";
        };
        "diffEditor.ignoreTrimWhitespace" = false;
        "gitlens.gitCommands.skipConfirmations" = [
          "fetch:command"
          "switch:command"
          "stash-push:command"
        ];
        "editor.inlineSuggest.enabled" = true;
        "github.copilot.enable" = {
          "*" = true;
          yaml = false;
          plaintext = false;
          markdown = true;
        };
        "githubPullRequests.pullBranch" = "never";
        "workbench.preferredLightColorTheme" = "Quiet Light";
        "workbench.preferredDarkColorTheme" = "Cursor Dark Midnight";
        "workbench.colorTheme" = "Quiet Light";
        "window.systemColorTheme" = "auto";
        "window.autoDetectColorScheme" = true;
      };
    };
  };
}
