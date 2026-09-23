# Host: milliways (Framework Laptop 13, Ryzen AI 300, systemd-boot, LUKS)
{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    # amdgpu (incl. early KMS), amd-pstate, fwupd, the PSR hang workaround and
    # the blacklist for the ACP audio device the BIOS wrongly reports as wired.
    # VA-API on the Radeon iGPU comes from Mesa itself, so unlike tuxedo there
    # is no extra driver to add for hardware video encoding.
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series

    ../../modules/core.nix
    ../../modules/hardware.nix
    ../../modules/desktop.nix
    ../../modules/packages.nix
    ../../modules/services.nix
    ../../modules/users.nix
  ];

  networking.hostName = "milliways";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # LUKS: the installer puts the root device's boot.initrd.luks.devices entry
  # in hardware-configuration.nix, but any other encrypted partition (swap) goes
  # into /etc/nixos/configuration.nix. Copy those lines here as they are.
  # boot.initrd.luks.devices."luks-<uuid>".device = "/dev/disk/by-uuid/<uuid>";

  # Copy the value from the installer's /etc/nixos/configuration.nix -- it is the
  # release this machine was installed with, not tuxedo's.
  system.stateVersion = "26.05"; # Did you read the comment?
}
