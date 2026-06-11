{ config, lib, pkgs, ... }:
let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
  musicFolder = "${home}/Music/Library";
  dataDir = "${home}/Library/Application Support/nix/navidrome";
  settingsFormat = pkgs.formats.json { };
  brewBin = "${config.homebrew.prefix}/bin";
  secretsFile = "${home}/.config/nix-darwin/secrets/navidrome.env";
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
    script = ''
      set -a
      . "${secretsFile}"
      set +a
      exec "${config.homebrew.prefix}/bin/navidrome" --configfile "${navidromeConfig}"
    '';
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      WorkingDirectory = dataDir;
    };
  };

  system.activationScripts.postActivation.text = lib.mkAfter ''
    mkdir -p "${dataDir}"
    chown ${user}:staff "${dataDir}"

    if [ ! -f "${secretsFile}" ]; then
      echo "warning: ${secretsFile} not found; copy secrets/navidrome.env.example and add your Last.fm keys" >&2
    fi
  '';
}
