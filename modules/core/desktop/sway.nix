{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf (config.core.desktop == "sway") {
    #------------------------------------------
    # GDM wayland only
    #------------------------------------------
    # https://github.com/NixOS/nixpkgs/issues/57602#issuecomment-657762138

    # enable sway window manager
    programs.sway = {
      enable = true;
      wrapperFeatures.base = true;
      wrapperFeatures.gtk = true; # so that gtk works properly
      extraPackages = with pkgs; [
        swaylock # lockscreen
        swayidle
        foot # default terminal (for iso)
        xwayland # for legacy apps
        waybar # status bar
        swaynotificationcenter # notification daemon
        kanshi # autorandr
        dmenu
        wofi # replacement for dmenu
        brightnessctl
        gammastep # make it red at night!
        sway-contrib.grimshot # screenshots
        swayr
        himalaya
        birdtray # email tray

        gnome-system-monitor
        mate.caja
        nautilus
        evince

        # https://discourse.nixos.org/t/some-lose-ends-for-sway-on-nixos-which-we-should-fix/17728/2?u=senorsmile
        adwaita-icon-theme # default gnome cursors
        glib # gsettings
        dracula-theme # gtk theme (dark)
      ];
    };
  };
}
