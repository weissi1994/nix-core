# Provides reasonable defaults to get started... mainly
# stuff to ensure your system can reliably rebuild this flake
# in the future.

{ inputs, ... }: {
  apps.desktop-config = {
    tags = [ "desktop" ];
    nixos = { host, pkgs, lib, ... }: {
      hardware = { graphics = { enable = true; }; };
      hardware.enableRedistributableFirmware = true;
      services.opensnitch = {
        enable = true;
        settings = {
          DefaultAction = "deny";
          DefaultDuration = "until restart";
        };
        rules = {
          systemd-timesyncd = {
            name = "systemd-timesyncd";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd";
            };
          };
          systemd-resolved = {
            name = "systemd-resolved";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-resolved";
            };
          };
          nsncd = {
            name = "nsncd";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.nsncd}/bin/nsncd";
            };
          };
          openssh = {
            name = "openssh";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.openssh}/bin/ssh";
            };
          };
          nix = {
            name = "nix";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.nix}/bin/nix";
            };
          };
          curl = {
            name = "curl";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.curl}/bin/curl";
            };
          };
          git-remote-http = {
            name = "git-remote-http";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.git}/libexec/git-core/git-remote-http";
            };
          };
          fwupd = {
            name = "fwupd";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.fwupd}/bin/.fwupdmgr-wrapped";
            };
          };
          podman = {
            name = "allow-podman";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.conmon}/bin/conmon";
            };
          };
          cloudflared = {
            name = "allow-cloudflared";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.cloudflared}/bin/cloudflared";
            };
          };
        };
      };
      services = {
        xserver = {
          enable = true;
          xkb.layout = "us,de";
          displayManager = {
            gdm.enable = true;
            gdm.wayland = true;
          };
        };
        dbus.enable = true;
        dbus.packages =
          [ pkgs.swaynotificationcenter pkgs.gcr pkgs.gnome-settings-daemon ];
        gnome.gnome-keyring.enable = true;
        gvfs.enable = true;
        fstrim.enable = true;

        displayManager.autoLogin = {
          enable = true;
          user = "${host.username}";
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
          hyprland.default = [ "gtk" "hyprland" ];
        };
        # gtk portal needed to make gtk apps happy
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };

      powerManagement.enable = true;
      powerManagement.powertop.enable = true;
      programs.dconf.enable = true;
      boot = {
        kernelParams =
          [ "quiet" "vt.global_cursor_default=0" "mitigations=off" ];
        plymouth.enable = true;
      };

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
              if (builtins.isString host.desktop) then true else false;
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

      # Disable xterm
      services.xserver.excludePackages = [ pkgs.xterm ];
      services.xserver.desktopManager.xterm.enable = false;

      environment.systemPackages = with pkgs; [
        nvme-cli
        smartmontools
        gsmartcontrol
        alsa-utils
        xorg.xhost
        pulseaudioFull
        pulsemixer
        pavucontrol
        libreoffice
        pick-colour-picker
        kitty
        wezterm

        # Fast moving apps use the unstable branch
        signal-desktop
        google-chrome
        tdesktop
      ];

      services = {
        smartd.enable = true;
        pulseaudio.enable = lib.mkForce false;
        pipewire = {
          enable = true;
          alsa.enable = true;
          jack.enable = true;
          pulse.enable = true;
          wireplumber.enable = true;
        };
        tlp = {
          enable = false;
          settings = {
            CPU_SCALING_GOVERNOR_ON_AC = "performance";
            CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

            CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
            CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

            CPU_MIN_PERF_ON_AC = 0;
            CPU_MAX_PERF_ON_AC = 100;
            CPU_MIN_PERF_ON_BAT = 0;
            CPU_MAX_PERF_ON_BAT = 20;

            #Optional helps save long term battery health
            START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
            STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
          };
        };

        thermald.enable = true;

        auto-cpufreq.enable = true;
        auto-cpufreq.settings = {
          battery = {
            governor = "powersave";
            turbo = "never";
          };
          charger = {
            governor = "performance";
            turbo = "auto";
          };
        };

        logind = {
          lidSwitchExternalPower = "suspend-then-hibernate";
          lidSwitch = "suspend-then-hibernate";
          lidSwitchDocked = "suspend-then-hibernate";
          extraConfig = ''
            IdleAction=suspend-then-hibernate
            IdleActionSec=10m
            # don’t shutdown when power button is short-pressed
            HandlePowerKey=ignore
          '';
        };
      };
      hardware.alsa.enablePersistence = true;
      stylix = {
        enable = true;
        image = ./background.png;

        polarity = "dark";

        base16Scheme =
          lib.mkForce "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
        targets.plymouth.logo = pkgs.fetchurl {
          url =
            "https://raw.githubusercontent.com/NixOS/nixos-artwork/f84c13adae08e860a7c3f76ab3a9bef916d276cc/logo/nix-snowflake-colours.svg";
          sha256 = "pHYa+d5f6MAaY8xWd3lDjhagS+nvwDL3w7zSsQyqH7A=";
        };

        fonts = {
          serif = {
            package = pkgs.dejavu_fonts;
            name = "DejaVu Serif";
          };

          sansSerif = {
            package = pkgs.dejavu_fonts;
            name = "DejaVu Sans";
          };

          monospace = {
            package = pkgs.fira-code;
            name = "Fira Code";
          };

          emoji = {
            package = pkgs.noto-fonts-emoji;
            name = "Noto Color Emoji";
          };
        };
      };

      systemd.sleep.extraConfig = "HibernateDelaySec=5m";
      fonts = {
        fontDir.enable = true;
        packages = with pkgs; [
          nerd-fonts.fira-code
          nerd-fonts.ubuntu-mono
          fira-code
          fira-code-symbols
          fira-go
          victor-mono
          joypixels
          font-awesome
          liberation_ttf
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-emoji
          source-serif
          ubuntu_font_family
          work-sans
        ];

        # Enable a basic set of fonts providing several font styles and families and reasonable coverage of Unicode.
        enableDefaultPackages = true;

        fontconfig = {
          antialias = true;
          defaultFonts = {
            serif = [ "Source Serif" ];
            sansSerif = [ "Work Sans" "Fira Sans" "FiraGO" ];
            monospace =
              [ "FiraCode Nerd Font Mono" "SauceCodePro Nerd Font Mono" ];
            emoji = [
              "Noto Color Emoji"
              "Twitter Color Emoji"
              "JoyPixels"
              "Unifont"
              "Unifont Upper"
            ];
          };
          enable = true;
          hinting = {
            autohint = false;
            enable = true;
            style = "slight";
          };
          subpixel = {
            rgba = "rgb";
            lcdfilter = "light";
          };
        };
      };

    };
    home = { };
  };
  defaultTags = { desktop = true; };
}
