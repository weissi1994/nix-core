{ inputs, ... }: {
  apps.gaming-config = {
    tags = [ "gaming" ];
    nixos = { host, pkgs, ... }: {
      fonts.fontconfig.cache32Bit = true;
      hardware.steam-hardware.enable = true;
      hardware.graphics.enable32Bit = true;
      services.jack.alsa.support32Bit = true;
      services.pipewire.alsa.support32Bit = true;
      programs = {
        steam = {
          enable = true;

          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = false;

          gamescopeSession.enable = true;

          extraCompatPackages = [ pkgs.proton-ge-bin ];
        };

        gamescope = {
          enable = true;
          capSysNice = true;
          args = [ "--rt" "--expose-wayland" ];
        };
      };
    };
    home = { };
  };
  defaultTags = { gaming = false; };
}
