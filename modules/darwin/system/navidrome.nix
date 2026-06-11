{ config, lib, pkgs, ... }:
let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
  musicFolder = "${home}/Music/Library";
  dataDir = "${home}/Library/Application Support/nix/navidrome";
  settingsFormat = pkgs.formats.json { };
  brewBin = "${config.homebrew.prefix}/bin";
  navidromeConfig = settingsFormat.generate "navidrome.json" {
    MusicFolder = musicFolder;
    DataFolder = dataDir;
    Address = "0.0.0.0";
    Port = 4533;
    EnableInsightsCollector = false;
    FFmpegPath = "${brewBin}/ffmpeg";
  };
in
{
  launchd.user.agents.navidrome = {
    path = [ brewBin ];
    serviceConfig = {
      ProgramArguments = [
        "${config.homebrew.prefix}/bin/navidrome"
        "--configfile"
        "${navidromeConfig}"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      WorkingDirectory = dataDir;
    };
  };

  system.activationScripts.postActivation.text = lib.mkAfter ''
    mkdir -p "${dataDir}"
    chown ${user}:staff "${dataDir}"
  '';
}
