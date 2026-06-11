{ config, lib, pkgs, ... }:
let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
  musicFolder = "${home}/Music/Library";
  dataDir = "${home}/Library/Application Support/nix/navidrome";
  pluginsDir = "${dataDir}/plugins";
  settingsFormat = pkgs.formats.json { };
  brewBin = "${config.homebrew.prefix}/bin";
  secretsFile = "${home}/.config/nix-darwin/secrets/navidrome.env";
  appleMusicPlugin = pkgs.fetchurl {
    url = "https://github.com/navidrome/apple-music-plugin/releases/download/v0.2.0/apple-music.ndp";
    hash = "sha256-NoJ1HnLKpcxGs/ercN5w6gJvCjikf3gLLStJIu0K0VQ=";
  };
  navidromeConfig = settingsFormat.generate "navidrome.json" {
    MusicFolder = musicFolder;
    DataFolder = dataDir;
    Address = "0.0.0.0";
    Port = 4533;
    EnableInsightsCollector = false;
    FFmpegPath = "${brewBin}/ffmpeg";
    Agents = "apple-music,lastfm";
    Plugins = {
      Enabled = true;
      Folder = pluginsDir;
    };
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
    mkdir -p "${pluginsDir}"
    install -m 644 ${appleMusicPlugin} "${pluginsDir}/apple-music.ndp"
    chown -R ${user}:staff "${dataDir}"

    if [ ! -f "${secretsFile}" ]; then
      echo "warning: ${secretsFile} not found; copy secrets/navidrome.env.example and add your Last.fm keys" >&2
    fi
  '';
}
