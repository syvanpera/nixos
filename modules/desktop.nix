# Wayland compositors, display manager, keymap, fonts and session variables.
{ lib, pkgs, inputs, ... }:

let
  # embeddedTheme picks which Themes/<name>.conf the theme's metadata.desktop
  # points at. Variants ship in the same package; see Themes/ upstream.
  sddm-astronaut = pkgs.sddm-astronaut.override { embeddedTheme = "pixel_sakura"; };
in
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs.niri.enable = true;

  programs.localsend.enable = true;

  # ydotool synthesises input through a virtual device, so whatever can reach
  # ydotoold's socket can type into whichever window has focus -- including a
  # terminal holding a cached sudo timestamp. Keep that off by default: the
  # socket is gated on the ydotool group (see users.nix) and the unit is
  # dropped from multi-user.target, so the capability exists only between an
  # explicit `systemctl start ydotoold` and the matching stop.
  programs.ydotool.enable = true;
  systemd.services.ydotoold.wantedBy = lib.mkForce [ ];

  # Each start of ydotoold is its own password prompt. The systemd action
  # defaults to auth_admin_keep, which caches the approval as a temporary
  # authorisation for the rest of the login session -- that would let anything
  # running as the user re-open the capability silently once it had been
  # granted the first time. AUTH_ADMIN drops the caching; the admin identity
  # itself is unix-group:wheel, set by the NixOS default addAdminRule.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "ydotoold.service") {
        return polkit.Result.AUTH_ADMIN;
      }
    });
  '';

  programs.chromium = {
    enable = true;
    extensions = [
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
    ];
  };

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;

      # Theme name, not a path: the module points SDDM's ThemeDir at
      # /run/current-system/sw/share/sddm/themes, which is why the theme
      # package has to land in environment.systemPackages below.
      theme = "sddm-astronaut-theme";

      # The theme's QML pulls in qtsvg / qtmultimedia / qtvirtualkeyboard. The
      # package only propagates those at build time, so hand them to the
      # greeter's plugin path explicitly.
      extraPackages = sddm-astronaut.propagatedBuildInputs;
    };

    defaultSession = "hyprland-uwsm";
  };

  # Kept here rather than in packages.nix: this isn't a tool to use, it's only
  # in the system profile because that's where SDDM looks for themes.
  environment.systemPackages = [ sddm-astronaut ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fi";
    variant = "nodeadkeys";
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.open-dyslexic
    pkgs.nerd-fonts.meslo-lg
    pkgs.nerd-fonts.ubuntu
    pkgs.nerd-fonts.ubuntu-mono
    pkgs.nerd-fonts.ubuntu-sans
    pkgs.material-symbols

    (pkgs.google-fonts.override { fonts = [ "Manrope" ]; })

    inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro-nerd
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "SF Pro Display" ];
    };
  };

  # GTK icon theme, set system-wide (no home-manager).
  #
  # GTK apps query xdg-desktop-portal-gtk first, and that backend reads these
  # GSettings keys out of dconf -- so the dconf default is what actually wins.
  # Without it the portal hands back the schema default ("Adwaita"), which
  # overrides anything coming from settings.ini.
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        icon-theme = "MoreWaita";
      };
    }
  ];

  # Fallback for GTK apps that never reach the portal (no portal running, or a
  # non-Wayland context). /etc/xdg is on XDG_CONFIG_DIRS, which is where GTK
  # looks for the system-level settings.ini.
  environment.etc = {
    "xdg/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-icon-theme-name=MoreWaita
    '';
    "xdg/gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-icon-theme-name=MoreWaita
    '';

    # Where the XDG user directories point. Nothing on this machine defined them
    # before, so ~/.config/user-dirs.dirs did not exist and anything asking where
    # to put a file fell back to $HOME. grimblast reads that file directly to
    # decide where a screenshot goes, and kuori reads it for recordings.
    #
    # SCREENSHOTS is not one of the eight keys xdg-user-dirs manages, so it may
    # be ignored here; screenshots then land in PICTURES, which is the fallback
    # grimblast uses anyway.
    "xdg/user-dirs.defaults".text = ''
      DESKTOP=Desktop
      DOWNLOAD=Downloads
      TEMPLATES=Templates
      PUBLICSHARE=Public
      DOCUMENTS=Documents
      MUSIC=Music
      PICTURES=Pictures
      VIDEOS=Videos
      SCREENSHOTS=Pictures/Screenshots
    '';
  };

  # Qt apps follow the GTK settings above, via the gtk3 platform theme plugin
  # that qtbase already ships (libqgtk3.so, present for both qt5 and qt6). It
  # reads gtk-icon-theme-name straight out of GtkSettings, so there's one
  # source of truth rather than a parallel qt6ct config to keep in sync.
  #
  # qt.platformTheme is left null on purpose: the module's enum has no "gtk3"
  # option, so QT_QPA_PLATFORMTHEME is set directly below. qt.enable is still
  # wanted for the QT_PLUGIN_PATH / QML2_IMPORT_PATH it sets up.
  qt.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORMTHEME = "gtk3";
    QML_IMPORT_PATH = "${pkgs.kdePackages.qtmultimedia}/lib/qt-6/qml:${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml";
    EDITOR = "nvim";
  };
}
