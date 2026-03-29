{ self, ... }:
{
  imports = [
    ./core.nix
    ./postgresql.nix
    ./redis.nix
    ./defaults/workspace.nix
    ./defaults/security-display.nix
    ./defaults/applications.nix
  ];
}
