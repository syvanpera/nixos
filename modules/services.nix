# Systemd services
{ lib, pkgs, inputs, ... }:

let
  awww = inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww;

  wl-paste = lib.getExe' pkgs.wl-clipboard "wl-paste";
  cliphist = lib.getExe pkgs.cliphist;

  # A password manager marks its clipboard offer with x-kde-passwordManagerHint.
  # Without this check every password copied would land in ~/.cache/cliphist/db
  # in plain text, and stay there for 750 copies; cliphist 0.7.0 has no ignore
  # of its own, so the filter has to sit in front of it.
  #
  # wl-paste runs this once per offer, and by then the offer being asked about is
  # the new one -- so --list-types describes the thing about to be stored.
  storeUnlessSecret = pkgs.writeShellScript "cliphist-store-text" ''
    ${wl-paste} --list-types | ${lib.getExe pkgs.gnugrep} -q x-kde-passwordManagerHint && exit 0

    exec ${cliphist} store
  '';
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

  # Generates ~/.config/user-dirs.dirs from /etc/xdg/user-dirs.defaults. The
  # package ships its own unit, but a unit that merely exists is never started --
  # it needs something to want it, which is what this is.
  #
  # Oneshot: it writes the file and exits. Re-running is how a change to the
  # defaults reaches an account that already has the file.
  systemd.user.services.xdg-user-dirs-update = {
    enable = true;
    description = "Create the XDG user directories";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe' pkgs.xdg-user-dirs "xdg-user-dirs-update";
    };
  };

  # Night light. hyprsunset applies a colour temperature to the whole output and
  # is controlled at runtime through hyprctl, which talks to a socket that only
  # exists while the daemon does -- so it runs from login rather than being
  # started by whatever wants to change the temperature.
  #
  # -i is the identity matrix: running, and changing nothing, until the shell
  # says otherwise. Without it the daemon would apply its own 6000K default at
  # every login, which is a colour change nobody asked for.
  systemd.user.services.hyprsunset = {
    enable = true;
    description = "Colour temperature for the display";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.hyprsunset} -i";
      Slice = "session.slice";
      Restart = "on-failure";
    };
  };

  # Clipboard history. cliphist is a store, not a daemon: nothing is ever
  # recorded unless wl-paste watches the selection and feeds it, so this has to
  # be a session service. History collected only while a launcher is open would
  # be no history at all.
  #
  # Two watchers rather than one bare `wl-paste --watch`, which is how cliphist's
  # own README splits it: one per type, so a copied image does not also arrive as
  # whatever text the source offers alongside it.
  systemd.user.services.cliphist-text = {
    enable = true;
    description = "Record copied text in the clipboard history";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${wl-paste} --type text --watch ${storeUnlessSecret}";
      Slice = "session.slice";
      Restart = "on-failure";
    };
  };

  # No secret filter on this one: a password manager offers text, and an image
  # cannot carry the hint in a way worth a process per copy.
  systemd.user.services.cliphist-image = {
    enable = true;
    description = "Record copied images in the clipboard history";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${wl-paste} --type image --watch ${cliphist} store";
      Slice = "session.slice";
      Restart = "on-failure";
    };
  };

  # The desktop shell: the border, the notches and the launcher, and since it
  # gained a polkit agent, the thing that answers authorisation prompts too.
  #
  # A unit rather than an exec-once in the Hyprland config, because it is now
  # load-bearing: Restart=on-failure means a crash does not silently leave the
  # session with no authentication agent, and the journal gets the output without
  # wrapping anything in systemd-cat.
  systemd.user.services.kuori = {
    enable = true;
    description = "kuori desktop shell";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe' pkgs.quickshell "quickshell"} -p %h/.config/kuori";

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
