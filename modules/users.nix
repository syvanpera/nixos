# User accounts. Don't forget to set a password with `passwd`.
{ pkgs, ... }:

{
  users.users."tuomo" = {
    isNormalUser = true;
    description = "Tuomo Syvänperä";
    # ydotool rather than uinput: uinput grants open(/dev/uinput) to every
    # process running as this user, which is the whole input-synthesis
    # capability, permanently. The ydotool group only opens the daemon's
    # socket, and that daemon is started on demand (see desktop.nix).
    extraGroups = [ "networkmanager" "wheel" "ydotool" "video" ];
    packages = with pkgs; [ ];
  };
}
