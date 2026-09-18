# Wayland compositors, display manager, keymap, fonts and session variables.
{ pkgs, inputs, ... }:

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs.niri.enable = true;

  programs.localsend.enable = true;

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
    };

    defaultSession = "hyprland-uwsm";
  };

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
