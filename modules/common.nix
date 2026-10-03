# Settings shared by every system in the flake, the hosts and the Incus
# container image alike: Nix daemon settings, locale and shell defaults.
{ lib, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Collect garbage weekly so old generations do not pile up.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 2d";
  };

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fi_FI.UTF-8";
    LC_IDENTIFICATION = "fi_FI.UTF-8";
    LC_MEASUREMENT = "fi_FI.UTF-8";
    LC_MONETARY = "fi_FI.UTF-8";
    LC_NAME = "fi_FI.UTF-8";
    LC_NUMERIC = "fi_FI.UTF-8";
    LC_PAPER = "fi_FI.UTF-8";
    LC_TELEPHONE = "fi_FI.UTF-8";
    LC_TIME = "fi_FI.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "fi";

  # clear all default shell aliases
  environment.shellAliases = lib.mkForce { };

  programs.fish.enable = true;
}
