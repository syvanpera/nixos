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
    # incus rather than incus-admin for the same reason: incus-admin is full
    # control of incusd, which is root on the host in all but name. incus only
    # reaches incus-user, which confines this account to its own restricted
    # project, still allowing raw.idmap of its own UID/GID and disk mounts
    # under its home, which is all innom needs.
    extraGroups = [ "networkmanager" "wheel" "input" "ydotool" "video" "incus" ];
    packages = with pkgs; [ ];
  };
}
