# Host: tuxedo (Intel laptop, systemd-boot, ext4)
{ ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/core.nix
    ../../modules/hardware.nix
    ../../modules/desktop.nix
    ../../modules/packages.nix
    ../../modules/users.nix
  ];

  networking.hostName = "tuxedo";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # This option defines the first version of NixOS you have installed on this
  # particular machine, and is used to maintain compatibility with application
  # data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any
  # reason, even if you've upgraded your system to a new NixOS release.
  #
  # See https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "26.05"; # Did you read the comment?
}
