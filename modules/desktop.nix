# Wayland compositors, display manager, keymap, fonts and session variables.
{ pkgs, inputs, ... }:

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

  programs.ydotool.enable = true;

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

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QML_IMPORT_PATH = "${pkgs.kdePackages.qtmultimedia}/lib/qt-6/qml:${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml";
    EDITOR = "nvim";
  };
}
