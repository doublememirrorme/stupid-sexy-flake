{ self, ... }:
{
  nixpkgs.config.allowUnfree = true;

  system = {
    primaryUser = "hcanadjija";
    configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 6;
  };

  users.users.hcanadjija = {
    name = "hcanadjija";
    home = "/Users/hcanadjija";
  };

  nix.settings.experimental-features = "nix-command flakes";

  # Without this, every rebuild is retained forever. 116 generations had piled
  # up between March and August 2026, holding the store at 29G; collecting them
  # brought it to 6.7G.
  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 7;
      Hour = 3;
      Minute = 15;
    };
    options = "--delete-older-than 30d";
  };

  # Hardlinks identical files in the store. Runs an hour after the gc so the two
  # are not walking the store at the same time.
  nix.optimise = {
    automatic = true;
    interval = {
      Weekday = 7;
      Hour = 4;
      Minute = 15;
    };
  };
}
