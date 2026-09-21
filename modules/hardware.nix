# Bluetooth, audio, power and input devices.
{ pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to 'false'.
        FastConnectable = false;
      };
      Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
  };

  hardware.acpilight.enable = true;

  # Hardware video encoding on the Intel iGPU, which is what /dev/dri/renderD128
  # is on this machine. The driver has to be here rather than in
  # environment.systemPackages: libva looks in /run/opengl-driver/lib/dri, and
  # only hardware.graphics.extraPackages puts anything there. Installed the other
  # way it is present on disk and invisible to every program that wants it.
  #
  # wf-recorder asks for h264_vaapi and **exits** if the connection fails rather
  # than falling back, so without this a recording does not merely run slowly --
  # it does not happen.
  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };

  services.upower.enable = true;

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "overload(control, esc)";
          };
        };
      };
    };
  };
}
