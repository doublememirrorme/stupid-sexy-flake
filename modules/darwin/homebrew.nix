{
  homebrew = {
    enable = true;
    enableZshIntegration = true;
    brews = [
      "nvm"
      "bandcamp-dl"
      "ffmpeg"
      "mpv"
      "navidrome"
    ];
    taps = [
      "kgarner7/feishin"
    ];
    casks = [
      "firefox"
      "google-chrome"
      "zen"
      "docker-desktop"
      "figma"
      "google-drive"
      "openemu"
      "emby"
      "embyserver"
      "feishin"
      "steam"
      # Ships its own updater, so greedy is needed for brew to track its version
      {
        name = "claude";
        greedy = true;
      }
    ];
    masApps = {
      "AdGuard for Safari" = 1440147259;
      "Animoog Z" = 1586841361;
      "Spark" = 1176895641;
    };
    onActivation.cleanup = "zap";
  };
}
