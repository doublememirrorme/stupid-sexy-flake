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
}
