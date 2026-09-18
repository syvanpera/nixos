# Systemd services
{ pkgs, inputs, ... }:

{
  systemd.user.services.awww-daemon = {
    enable = true;
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    description = "An Answer to your Wayland Wallpaper Woes";
    serviceConfig = {
        Type = "simple";
        ExecStart = ''/run/current-system/sw/bin/awww-daemon'';
    };
  };
}
