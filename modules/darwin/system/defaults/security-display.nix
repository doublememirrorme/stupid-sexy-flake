# Launch Services, screen lock, captures, window tiling, Activity Monitor, /Library plists
_: {
  system.defaults = {
    LaunchServices.LSQuarantine = false;

    screencapture = {
      target = "clipboard";
      disable-shadow = true;
    };

    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 0;
    };

    WindowManager.EnableTiledWindowMargins = false;

    ActivityMonitor = {
      OpenMainWindow = true;
      IconType = 5;
      ShowCategory = 100;
      SortColumn = "CPUUsage";
      SortDirection = 0;
    };

    CustomSystemPreferences = {
      "/Library/Preferences/com.apple.loginwindow" = {
        showInputMenu = true;
      };
      "/Library/Preferences/com.apple.windowserver" = {
        DisplayResolutionEnabled = true;
      };
      "/Library/Preferences/com.apple.SoftwareUpdate" = {
        AutomaticDownload = true;
        CriticalUpdateInstall = false;
      };
    };
  };
}
