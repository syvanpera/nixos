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

  # Polkit authentication agent for the Hyprland session. Without one running,
  # anything needing authorisation (`systemctl start ydotoold`, say) can only
  # be authorised by typing a password into a terminal; with it, the request
  # surfaces as a desktop prompt.
  #
  # Declared here rather than via systemd.packages so the unit matches the
  # style above and pins the store path. Note ExecStart is under libexec/,
  # not bin/, so lib.getExe' does not apply.
  systemd.user.services.hyprpolkitagent = {
    enable = true;
    description = "Hyprland Polkit Authentication Agent";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Slice = "session.slice";
      TimeoutStopSec = "5sec";
      Restart = "on-failure";
    };
  };
}
