{ config, ... }:
{
  services = {
    xserver = {
      enable = true;
      xkb.layout = "us,de";
    };

    displayManager.autoLogin = {
      enable = true;
      user = "${config.core.username}";
    };
    libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = true;
        middleEmulation = true;
        tapping = true;
      };
    };
  };
  # To prevent getting stuck at shutdown
  # systemd.extraConfig = "DefaultTimeoutStopSec=10s";
}
