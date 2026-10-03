# Networking and other machine-level defaults for the hosts. Nix, locale and
# shell settings shared with the container image live in common.nix.
{ ... }:

{
  imports = [ ./common.nix ];

  # Enable networking
  networking.networkmanager.enable = true;

  # With the dock's Ethernet and Wi-Fi on the same subnet, Linux by default
  # answers ARP for any local IP on any interface, so the router can learn the
  # Ethernet IP under the Wi-Fi MAC. Every Wi-Fi roam or switch-off then drops
  # the wired connection until the router re-ARPs (seconds up to ~45 s).
  # Only answer ARP for addresses on the receiving interface, and source ARP
  # requests from the outgoing interface's own address.
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.arp_ignore" = 1;
    "net.ipv4.conf.all.arp_announce" = 2;
  };

  # Home network hosts
  networking.hosts = {
    "10.0.0.1" = [ "moria" ];
    "10.0.0.4" = [ "unifi" ];
    "10.0.0.10" = [ "pve" ];
    "10.0.0.11" = [ "hass" ];
    "10.0.0.12" = [ "zigbee2mqtt" ];
    "10.0.0.13" = [ "mqtt" ];
    "10.0.0.14" = [ "mariadb" ];
    "10.0.0.15" = [ "hermes" ];
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

  # Never let uv download its own CPython: python-build-standalone binaries
  # expect /lib64/ld-linux-x86-64.so.2, which does not exist on NixOS.
  environment.variables.UV_PYTHON_DOWNLOADS = "never";

  services.power-profiles-daemon.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
}
