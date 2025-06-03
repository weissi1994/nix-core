{ inputs, lib, ... }: {
  apps.waybar-config = {
    tags = [ "desktop" ];
    enablePredicate = { host, ... }:
      host.desktop == "waybar" || host.desktop == "hyprland";

    nixos = { host, pkgs, ... }: { };

    home = { host, ... }: { };
  };
}
