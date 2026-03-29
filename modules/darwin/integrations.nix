{ pkgs, inputs, ... }:
{
  # Spotlight / Launchpad for HM-installed .app bundles (e.g. Cursor via programs.vscode)
  home-manager.sharedModules = [
    inputs.mac-app-util.homeManagerModules.default
  ];

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    autoMigrate = true;
    user = "hcanadjija";
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.hcanadjija = { pkgs, ... }: {
    imports = [ ./home/zsh.nix ];

    home.stateVersion = "25.05";

    programs.vscode = {
      enable = true;
      package = pkgs.code-cursor;
      mutableExtensionsDir = false;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        dbaeumer.vscode-eslint
        eamodio.gitlens
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-containers
        vscodevim.vim
        jnoortheen.nix-ide
        github.vscode-pull-request-github
      ];
    };
  };
}
