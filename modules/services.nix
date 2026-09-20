# Systemd services
{ lib, pkgs, inputs, ... }:

let
  awww = inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww;
in
{
  systemd.user.services.awww-daemon = {
    enable = true;
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    description = "An Answer to your Wayland Wallpaper Woes";
    serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe' awww "awww-daemon";
    };
  };
}
