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

        # The daemon starts with no wallpaper -- it shows black until something
        # tells it what to display -- and it already keeps its own cache of the
        # last image per output, so restoring is its job rather than the shell's.
        # It answers as soon as the process is up, so no waiting is needed here.
        #
        # Leading `-` because a machine that has never had a wallpaper set has
        # nothing to restore, and that is not a failed start.
        ExecStartPost = "-${lib.getExe' awww "awww"} restore";
    };
  };

  # The desktop shell: the border, the notches and the launcher, and since it
  # gained a polkit agent, the thing that answers authorisation prompts too.
  #
  # A unit rather than an exec-once in the Hyprland config, because it is now
  # load-bearing: Restart=on-failure means a crash does not silently leave the
  # session with no authentication agent, and the journal gets the output without
  # wrapping anything in systemd-cat.
  #
  # The config path is the working copy on purpose -- this shell is developed in
  # place. `-p` is not optional: ~/.config/quickshell holds an older copy and a
  # bare quickshell would load that one.
  systemd.user.services.kuori = {
    enable = true;
    description = "kuori desktop shell";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe' pkgs.quickshell "quickshell"} -p /home/tuomo/work/personal/kuori";

      # systemd hands a unit a minimal PATH -- coreutils, findutils, grep, sed,
      # systemd -- and this one inherits nothing from the session. Started from
      # hyprland the shell had the whole session PATH, so nothing needed saying;
      # as a unit it lost uwsm (launching an app), nmcli (the wifi band and the
      # IPv4 address), brightnessctl (naming the backlight) and ping, and each
      # of those failures is silent: the launcher simply stops launching.
      #
      # The session's own directories rather than a list of store paths, so a
      # tool the shell picks up later does not have to be added here too.
      Environment = [ "PATH=/run/wrappers/bin:/run/current-system/sw/bin" ];

      Slice = "session.slice";
      TimeoutStopSec = "5sec";
      Restart = "on-failure";
    };
  };
}
