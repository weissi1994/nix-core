{ lib, desktop, pkgs, ... }: {
  config = lib.mkIf (desktop != null) {
    home.packages = with pkgs; [
      ## Multimedia
      audacity
      gimp
      obs-studio
      pavucontrol
      vlc
      discord

      ## Office
      libreoffice
      gnome-calculator

      ## Utility
      dconf-editor
      gnome-disk-utility
      zenity
      wl-clipboard # clipboard utils for wayland (wl-copy, wl-paste)
    ];
  };
}
