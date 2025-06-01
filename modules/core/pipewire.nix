{
  pkgs,
  lib,
  config,
  ...
}:
{
  hardware.alsa.enablePersistence = true;
  environment.systemPackages =
    with pkgs;
    [
      alsa-utils
      pulseaudioFull
      pulsemixer
    ]
    ++ lib.optionals (config.core.desktop != null) [ pavucontrol ];

  services = {
    pulseaudio.enable = lib.mkForce false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };
}
