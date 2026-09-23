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

  # A "Framework Speakers" PipeWire sink that runs the speakers through bass
  # enhancement, loudness compensation and EQ; the raw speaker sink is hidden.
  # Leave the speakers at 100% -- the volumes compound -- and re-select the
  # default output if audio doesn't move over on its own. The raw device name
  # comes from the nixos-hardware module; if the sink doesn't appear, check it
  # with `pw-dump | grep -C 20 pci-0000` and set rawDeviceName here.
  hardware.framework.laptop13.audioEnhancement.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-092d804b-6569-4774-a75b-17b6aa3cda8e".device = "/dev/disk/by-uuid/092d804b-6569-4774-a75b-17b6aa3cda8e";

  system.stateVersion = "26.05"; # Did you read the comment?
}
