{ self, ... }:
{
  imports = [
    ./core.nix
    ./fonts.nix
    ./postgresql.nix
    ./redis.nix
    ./navidrome.nix
    ./defaults/workspace.nix
    ./defaults/security-display.nix
    ./defaults/applications.nix
  ];
}
