{
  description = "stupid-sexy-flake — nix-darwin + NixOS (Mac + hub)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      mac-app-util,
      nix-homebrew,
      ...
    }:
    let
      sharedModules = [ ./modules/shared ];
      # NixOS hub: set true when installing on QEMU/KVM (VirtIO initrd modules).
      hubQemuGuest = false;
    in
    {
      darwinConfigurations.hexley = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit self inputs; };
        modules = [
          mac-app-util.darwinModules.default
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
        ]
        ++ sharedModules
        ++ [
          ./modules/darwin
          ./machines/mac
        ];
      };

      nixosConfigurations.tux = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit self inputs hubQemuGuest;
        };
        modules = sharedModules ++ [
          ./modules/nixos
          ./machines/hub
        ];
      };
    };
}
