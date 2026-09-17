# Shared by cursor.nix (via programs.cursor) and vscode.nix (via programs.vscode).
# Per-editor overrides live in those two files, not here.
pkgs:
let
  # Neither of these is in nixpkgs, so they come straight from the marketplace.
  tinaciousDesign = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "tinaciousdesign";
      name = "theme-tinaciousdesign";
      version = "2.4.0";
      hash = "sha256-wrliL9OLz8oNyGzR7xh9dtiWkNWX0/N6PTjHVt8Whew=";
    };
  };

  # Provides the city-lights-icons-vsc-light icon theme set below.
  cityLightsIcons = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "Yummygum";
      name = "city-lights-icon-vsc";
      version = "1.1.3";
      hash = "sha256-TLbBJ9pjHuQE+1fQZ4nyg8Q9YpDXVCd+EbMdatF9ofE=";
    };
  };
in
{
  extensions = (with pkgs.vscode-extensions; [
    dbaeumer.vscode-eslint
    eamodio.gitlens
    ms-azuretools.vscode-docker
    ms-vscode-remote.remote-containers
    vscodevim.vim
    jnoortheen.nix-ide
    github.vscode-pull-request-github
    # Several defaultFormatter settings below already point at prettier.
    esbenp.prettier-vscode
  ]) ++ [
    tinaciousDesign
    cityLightsIcons
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
    "workbench.preferredLightColorTheme" = "Tinacious Design (Light)";
    "workbench.preferredDarkColorTheme" = "Tinacious Design";
    # Only used if window.autoDetectColorScheme is ever turned off.
    "workbench.colorTheme" = "Tinacious Design";
    "window.systemColorTheme" = "auto";
    "window.autoDetectColorScheme" = true;
    # Pin the Nix zsh, same as tmux.nix. Otherwise the editor falls back to $SHELL,
    # and the macOS login shell is still Apple's /bin/zsh.
    "terminal.integrated.profiles.osx" = {
      zsh = {
        path = "${pkgs.zsh}/bin/zsh";
        args = [ "-l" ];
      };
    };
    "terminal.integrated.defaultProfile.osx" = "zsh";
  };
}
