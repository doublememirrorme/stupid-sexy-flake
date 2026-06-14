{ config, lib, ... }:
{
  services.skhd = {
    enable = true;
    skhdConfig = builtins.readFile ./.skhdrc;
  };

  launchd.user.agents.skhd = {
    serviceConfig.ProgramArguments = lib.mkForce [
      "/bin/sh"
      "-c"
      "/bin/wait4path /nix/store && exec ${config.services.skhd.package}/bin/skhd -c /etc/skhdrc"
    ];
    serviceConfig.RunAtLoad = lib.mkDefault true;
  };
}
