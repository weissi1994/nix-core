{ config, lib, pkgs, ... }: {
  imports = [ ./sway.nix ./hyprland.nix ];
  config = lib.mkIf (config.core.desktop != null) {
    boot = {
      kernelParams = [ "quiet" "vt.global_cursor_default=0" "mitigations=off" ];
      plymouth.enable = true;
    };

    hardware = { graphics = { enable = true; }; };

    environment.sessionVariables = { _JAVA_AWT_WM_NONREPARENTING = "1"; };
    services = {
      printing.enable = true;
      #printing.drivers = with pkgs; [ gutenprint hplipWithPlugin ];
      printing.drivers = with pkgs; [ gutenprint ];
    };
    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
        publish = {
          addresses = false;
          enable = false;
          workstation =
            if (builtins.isString config.core.desktop) then true else false;
        };
      };
    };

    programs = {
      chromium = {
        extensions = [
          "hfjbmagddngcpeloejdejnfgbamkjaeg" # Vimium C
          "kkhfnlkhiapbiehimabddjbimfaijdhk" # gopass-bridge
        ];
      };
    };

    programs.dconf.enable = true;

    # Disable xterm
    services.xserver.excludePackages = [ pkgs.xterm ];
    services.xserver.desktopManager.xterm.enable = false;

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
    };

    environment.systemPackages = with pkgs; [
      libreoffice
      pick-colour-picker
      kitty
      wezterm

      # Fast moving apps use the unstable branch
      signal-desktop
      google-chrome
      tdesktop
    ];
  };
}
