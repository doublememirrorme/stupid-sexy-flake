# Default path is bare metal: merge `nixos-generate-config` for real disks and initrd modules.
# For QEMU/KVM guests, set `hubQemuGuest = true` in flake.nix (adds virtio modules in initrd).
{
  lib,
  modulesPath,
  hubQemuGuest,
  ...
}:
{
  imports = lib.optionals hubQemuGuest [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };
}
