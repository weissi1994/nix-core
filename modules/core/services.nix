{ pkgs, ... }:
{
  services = {
    dbus.enable = true;
    dbus.packages = [
      pkgs.swaynotificationcenter
      pkgs.gcr
      pkgs.gnome-settings-daemon
    ];
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    fstrim.enable = true;
    xserver = {
      enable = true;
      displayManager = {
        gdm.enable = true;
        gdm.wayland = true;
      };
    };
  };
  systemd.packages = [ pkgs.swaynotificationcenter ];

  # xdg-desktop-portal works by exposing a series of D-Bus interfaces
  # known as portals under a well-known name
  # (org.freedesktop.portal.Desktop) and object path
  # (/org/freedesktop/portal/desktop).
  # The portal interfaces include APIs for file access, opening URIs,
  security.polkit.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    xdgOpenUsePortal = true;
    config = {
      common.default = [ "gtk" ];
      hyprland.default = [
        "gtk"
        "hyprland"
      ];
    };
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.logind.extraConfig = ''
    # don’t shutdown when power button is short-pressed
    HandlePowerKey=ignore
  '';
}
