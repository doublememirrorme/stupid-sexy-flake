{ pkgs, inputs, ... }:
{
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
  home-manager.backupFileExtension = "backup";
  home-manager.users.hcanadjija = { pkgs, ... }: {
    imports = [
      ./home/zsh.nix
      ./home/iterm2.nix
      ./home/cursor.nix
    ];

    home.stateVersion = "25.05";
  };
}
