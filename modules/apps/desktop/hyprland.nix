{ inputs, lib, ... }: {
  apps.hyprland-config = {
    tags = [ "desktop" ];
    enablePredicate = { host, ... }: host.desktop == "hyprland";

    nixos = { host, pkgs, ... }: {
      programs.hyprland.enable = true;
      # programs.hyprland.package = inputs.hyprland.packages.${pkgs.system}.default;
      # programs.hyprland.portalPackage =
      #   inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
      # wayland.windowManager.hyprland = {
      #   enable = true;
      #   package = null;
      #   portalPackage = null;

      #   xwayland = {
      #     enable = true;
      #     # hidpi = true;
      #   };
      #   enableNvidiaPatches =
      #     lib.elem "nvidia" config.services.xserver.videoDrivers;
      #   systemd.enable = true;
      # };
    };

    home = { host, ... }: { };
  };
}
