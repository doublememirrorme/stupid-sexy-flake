# Dock, Finder, trackpad, keyboard-adjacent globals, mouse speed
_: {
  system.defaults = {
    dock = {
      autohide = true;
      dashboard-in-overlay = true;
      enable-spring-load-actions-on-all-items = true;
      expose-animation-duration = 0.2;
      expose-group-apps = false;
      mineffect = "genie";
      minimize-to-application = true;
      mouse-over-hilite-stack = true;
      mru-spaces = false;
      orientation = "bottom";
      show-process-indicators = true;
      show-recents = false;
      showLaunchpadGestureEnabled = false;
      showhidden = true;
      tilesize = 40;
      # nix-darwin: 1 = disabled (differs from legacy scripts that used 0)
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
      wvous-br-corner = 1;
      wvous-bl-corner = 1;
    };

    finder = {
      _FXShowPosixPathInTitle = true;
      _FXSortFoldersFirst = true;
      _FXSortFoldersFirstOnDesktop = true;
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "clmv";
      QuitMenuItem = true;
      NewWindowTarget = "Home";

      ShowPathbar = true;
      ShowStatusBar = true;

      ShowHardDrivesOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
      ShowExternalHardDrivesOnDesktop = true;
      ShowMountedServersOnDesktop = true;
    };

    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = false;
    };

    NSGlobalDomain = {
      AppleInterfaceStyleSwitchesAutomatically = true;

      AppleKeyboardUIMode = 3;
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 10;
      KeyRepeat = 1;

      AppleShowAllExtensions = true;
      AppleICUForce24HourTime = true;
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleTemperatureUnit = "Celsius";
      AppleFontSmoothing = 1;
      AppleScrollerPagingBehavior = false;

      "com.apple.trackpad.scaling" = 2.0;
      "com.apple.springing.delay" = 0.3;
      "com.apple.springing.enabled" = true;

      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;

      NSDisableAutomaticTermination = true;
      NSDocumentSaveNewDocumentsToCloud = false;

      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;

      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;

      NSStatusItemSpacing = 8;
      NSStatusItemSelectionPadding = 8;

      _HIHideMenuBar = false;
    };

    ".GlobalPreferences"."com.apple.mouse.scaling" = 1.5;
  };
}
