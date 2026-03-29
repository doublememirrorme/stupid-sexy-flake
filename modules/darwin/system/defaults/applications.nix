# Per-app domains and Control Center (no Safari: container sandbox breaks defaults write)
_: {
  system.defaults = {
    CustomUserPreferences = {
      "com.apple.driver.AppleBluetoothMultitouch.trackpad".TrackpadThreeFingerDrag = false;

      "com.apple.dashboard".mcx-disabled = true;

      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };

      "com.apple.frameworks.diskimages" = {
        auto-open-ro-root = true;
        auto-open-rw-root = true;
      };

      "com.apple.finder" = {
        OpenWindowForNewRemovableDisk = true;
        WarnOnEmptyTrash = false;
        QLEnableTextSelection = true;
        QLHidePanelOnDeactivate = true;
        QLEnableXRayFolders = true;
        FXInfoPanesExpanded = {
          General = true;
          OpenWith = true;
          Privileges = true;
        };
      };

      "com.apple.NetworkBrowser" = {
        BrowseAllInterfaces = true;
        EnableODiskBrowsing = true;
        ODSSupported = true;
      };

      "com.apple.menuextra.battery".ShowPercent = "YES";

      "com.apple.print.PrintingPrefs"."Quit When Finished" = true;

      "com.apple.appstore".ShowDebugMenu = true;
      "com.apple.commerce".AutoUpdate = true;

      "com.apple.CrashReporter".DialogType = "none";
      "com.apple.assistant.support"."Siri Data Sharing Opt-In Status" = 2;
      "com.apple.SubmitDiagInfo".AutoSubmit = false;

      "com.apple.ImageCapture".disableHotPlug = true;

      "com.apple.DiskUtility" = {
        DUDebugMenuEnabled = true;
        advanced-image-options = true;
      };

      "com.apple.TextEdit".RichText = 0;
      "com.apple.terminal".SecureKeyboardEntry = true;

      "com.googlecode.iterm2".PromptOnQuit = false;

      "-g" = {
        AppleAccentColor = 2;
        AppleHighlightColor = "1.000000 0.937255 0.690196 Yellow";
        AppleLanguages = [
          "en-US"
          "hr-HR"
        ];
        AppleLocale = "en_US@currency=EUR;rg=hr_HR";
        WebContinuousSpellCheckingEnabled = true;
      };

      "com.apple.ncprefs".dnd_prefs = {
        dndDisplayLock = true;
        dndDisplaySleep = true;
      };
    };

    controlcenter.BatteryShowPercentage = true;
  };
}
