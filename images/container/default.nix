# Image: a minimal headless Incus system container. Not a machine of its own;
# built into an image with `nix build .#incus-image` (see flake.nix). The
# packages it carries are defined separately in ./packages.nix.
{ modulesPath, ... }:

{
  imports = [
    # Pulls in the minimal profile, the Incus image metadata and the
    # system.build.squashfs rootfs the image is made from.
    "${modulesPath}/virtualisation/lxc-container.nix"

    ../../modules/common.nix
    ./packages.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  # Empty so no /etc/hostname is written and each instance keeps the hostname
  # Incus gives it, its own name.
  networking.hostName = "";

  # The store path name otherwise falls back to the hostname, which reads as
  # "unnamed" when it is empty.
  system.name = "nixos-container";

  # The LXC module copies a full nixpkgs checkout into the image as a channel
  # and a generated configuration.nix into /etc/nixos. Neither is needed: the
  # flake's nixpkgs is already pinned in the registry and NIX_PATH, and the
  # config lives in this flake.
  system.installer.channel.enable = false;
  installer.cloneConfig = false;

  # The LXC module turns documentation back on over the minimal profile.
  documentation.enable = false;

  # UID 1000 / GID 100 (users) like on the hosts, so the raw.idmap set up in
  # services.nix keeps the owner of files in folders shared into the container.
  users.users."tuomo" = {
    isNormalUser = true;
    uid = 1000;
    description = "Tuomo Syvänperä";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID1XunDrrXdJRzAEjXQebfrySRSaro5lccc0pdl8lYxG tuomo.syvanpera@gmail.com"
    ];
  };

  # The account has no password: it is reached through `incus exec` or the SSH
  # key above, so sudo cannot ask for one.
  security.sudo.wheelNeedsPassword = false;

  # Lets `nixos-rebuild --target-host` copy unsigned paths built on the host
  # into the store. Grants nothing new: wheel already has passwordless sudo.
  nix.settings.trusted-users = [ "@wheel" ];

  # sshd is enabled and socket-activated by the LXC module. Keys only, and no
  # root logins, since the module gives root an empty password.
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
  };

  system.stateVersion = "26.05"; # Did you read the comment?
}
