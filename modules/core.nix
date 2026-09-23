# Nix daemon settings, networking, locale and shell defaults.
{ lib, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Collect garbage weekly so old generations do not pile up.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 2d";
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Home network hosts
  networking.hosts = {
    "10.0.0.1" = [ "moria" ];
    "10.0.0.4" = [ "unifi" ];
    "10.0.0.10" = [ "pve" ];
    "10.0.0.11" = [ "hass" ];
    "10.0.0.12" = [ "zigbee2mqtt" ];
    "10.0.0.13" = [ "mqtt" ];
    "10.0.0.14" = [ "mariadb" ];
    "10.0.0.17" = [ "vault" ];
    "10.0.0.20" = [ "kuunappi" ];
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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

  # Never let uv download its own CPython: python-build-standalone binaries
  # expect /lib64/ld-linux-x86-64.so.2, which does not exist on NixOS.
  environment.variables.UV_PYTHON_DOWNLOADS = "never";

  # clear all default shell aliases
  environment.shellAliases = lib.mkForce { };

  programs.fish.enable = true;

  services.power-profiles-daemon.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
}
