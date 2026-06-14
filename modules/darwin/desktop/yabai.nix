{ config, lib, pkgs, ... }:
let
  yabairc = pkgs.writeScript "yabairc" ''
    ${builtins.readFile ./.yabairc}
  '';
  yabaiBin = "${config.services.yabai.package}/bin/yabai";
in
{
  # Managed by launchd as org.nixos.yabai. Do not run `yabai --start-service` (installs a
  # second LaunchAgent and fights this service).
  services.yabai = {
    enable = true;
    enableScriptingAddition = false;
    config = { };
    extraConfig = builtins.readFile ./.yabairc;
  };

  # nix-darwin points ProgramArguments at /nix/store directly; at login the store may not
  # be mounted yet, so launchd exits 78 and puts the job in penalty box (nix-darwin#1709).
  launchd.user.agents.yabai.serviceConfig.ProgramArguments = lib.mkForce [
    "/bin/sh"
    "-c"
    "/bin/wait4path /nix/store && exec ${yabaiBin} -c ${yabairc}"
  ];
}
