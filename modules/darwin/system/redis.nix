{ config, lib, pkgs, ... }:
let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
  dataDir = "${home}/Library/Application Support/nix/redis";
in
{
  services.redis = {
    enable = false;
    package = pkgs.redis;
    inherit dataDir;
    bind = "127.0.0.1";
  };

  system.activationScripts.postActivation.text = lib.mkAfter ''
    mkdir -p "${dataDir}"
    chown ${user}:staff "${dataDir}"
  '';
}
