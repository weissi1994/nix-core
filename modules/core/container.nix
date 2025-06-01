{
  config,
  desktop,
  lib,
  pkgs,
  ...
}:
{
  #https://nixos.wiki/wiki/Podman
  environment.systemPackages =
    with pkgs;
    [
      fuse-overlayfs
      podman-compose
      podman-tui
      unstable.podman
    ]
    ++ lib.optionals (desktop != null) [
      unstable.pods
      xorg.xhost
    ];

  hardware.nvidia-container-toolkit.enable = lib.elem "nvidia" config.services.xserver.videoDrivers;
  virtualisation = {
    podman = {
      defaultNetwork.settings = {
        dns_enabled = true;
      };
      autoPrune = {
        enable = true;
        flags = [ "--all" ];
      };
      dockerCompat = true;
      dockerSocket.enable = true;
      enable = true;
    };
  };
}
