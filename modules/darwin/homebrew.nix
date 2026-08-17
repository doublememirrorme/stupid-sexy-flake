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
    # kgarner7/feishin is declared in extraConfig instead, so it can carry `trusted:`.
    taps = [ ];
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

    # Recent brew refuses to load casks from third-party taps until they are trusted.
    # nix-darwin's `taps` option cannot emit the `trusted:` key, so declare the tap here.
    # Scoped to the feishin cask rather than trusting everything in the tap.
    extraConfig = ''
      tap "kgarner7/feishin", trusted: { casks: ["feishin"] }
    '';
  };
}
