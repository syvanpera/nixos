# Packages in the Incus container image. Independent of the hosts'
# modules/packages.nix: nothing from there ends up in the image.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    curl
    fd
    git
    htop
    jq
    ripgrep
    vim
  ];
}
