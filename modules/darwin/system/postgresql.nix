{ config, pkgs, ... }:
let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
in
{
  services.postgresql = {
    enable = false;
    package = pkgs.postgresql_18;
    dataDir = "${home}/Library/Application Support/nix/postgresql/${pkgs.postgresql_18.psqlSchema}";
  };
}
