{
  homebrew = {
    enable = true;
    enableZshIntegration = true;
    brews = [
      "nvm"
      "bandcamp-dl"
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
      "steam"
      "roon"
    ];
    masApps = {
      "AdGuard for Safari" = 1440147259;
      "Animoog Z" = 1586841361;
      "Spark" = 1176895641;
    };
    onActivation.cleanup = "zap";
  };
}
