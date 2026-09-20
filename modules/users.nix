# User accounts. Don't forget to set a password with `passwd`.
{ pkgs, ... }:

{
  users.users."tuomo" = {
    isNormalUser = true;
    description = "Tuomo Syvänperä";
    extraGroups = [ "networkmanager" "wheel" "uinput" ];
    packages = with pkgs; [ ];
  };
}
