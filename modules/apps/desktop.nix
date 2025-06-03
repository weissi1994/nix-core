{ inputs, lib, ... }: {
  apps.desktop-config = {
    tags = [ "desktop" ];
    nixos = { host, pkgs, lib, ... }: {
      hardware = { graphics = { enable = true; }; };
      hardware.enableRedistributableFirmware = true;
      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [ "joypixels" ];
      nixpkgs.config.joypixels.acceptLicense = true;
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
          # joypixels
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
              # "JoyPixels"
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
    home = { config, pkgs, ... }:
      let
        defaultApps = {
          browser = [ "zen-beta.desktop" ];
          text = [ "org.gnome.TextEditor.desktop" ];
          image = [ "imv-dir.desktop" ];
          audio = [ "mpv.desktop" ];
          video = [ "mpv.desktop" ];
          directory = [ "nemo.desktop" ];
          office = [ "libreoffice.desktop" ];
          pdf = [ "org.gnome.Evince.desktop" ];
          terminal = [ "ghostty.desktop" ];
          archive = [ "org.gnome.FileRoller.desktop" ];
          discord = [ "webcord.desktop" ];
        };

        mimeMap = {
          text = [ "text/plain" ];
          image = [
            "image/bmp"
            "image/gif"
            "image/jpeg"
            "image/jpg"
            "image/png"
            "image/svg+xml"
            "image/tiff"
            "image/vnd.microsoft.icon"
            "image/webp"
          ];
          audio = [
            "audio/aac"
            "audio/mpeg"
            "audio/ogg"
            "audio/opus"
            "audio/wav"
            "audio/webm"
            "audio/x-matroska"
          ];
          video = [
            "video/mp2t"
            "video/mp4"
            "video/mpeg"
            "video/ogg"
            "video/webm"
            "video/x-flv"
            "video/x-matroska"
            "video/x-msvideo"
          ];
          directory = [ "inode/directory" ];
          browser = [
            "text/html"
            "x-scheme-handler/about"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/unknown"
          ];
          office = [
            "application/vnd.oasis.opendocument.text"
            "application/vnd.oasis.opendocument.spreadsheet"
            "application/vnd.oasis.opendocument.presentation"
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            "application/vnd.openxmlformats-officedocument.presentationml.presentation"
            "application/msword"
            "application/vnd.ms-excel"
            "application/vnd.ms-powerpoint"
            "application/rtf"
          ];
          pdf = [ "application/pdf" ];
          terminal = [ "terminal" ];
          archive = [
            "application/zip"
            "application/rar"
            "application/7z"
            "application/*tar"
          ];
          discord = [ "x-scheme-handler/discord" ];
        };

        associations = with lib.lists;
          lib.listToAttrs (lib.flatten (lib.mapAttrsToList (key:
            lib.map
            (type: lib.attrsets.nameValuePair type defaultApps."${key}"))
            mimeMap));
      in {
        xdg = {
          enable = true;
          configFile."mimeapps.list".force = true;
          mimeApps = {
            enable = true;
            associations.added = associations;
            defaultApplications = associations;
          };
          userDirs = {
            enable = true;
            createDirectories = lib.mkDefault true;
            extraConfig = {
              XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Screenshots";
            };
          };
        };
        # https://nixos.wiki/wiki/Bluetooth#Using_Bluetooth_headsets_with_PulseAudio
        services.mpris-proxy.enable = true;

        services.opensnitch-ui.enable = true;

        services.gnome-keyring.enable = true;

        services.gpg-agent = {
          enable = true;
          pinentry.package = pkgs.pinentry-gnome3;
          defaultCacheTtl = 1800;
          maxCacheTtl = 28800;
          defaultCacheTtlSsh = 1800;
          maxCacheTtlSsh = 7200;
        };

        xresources.properties = {
          "XTerm*faceName" =
            "FiraCode Nerd Font:size=13:style=Medium:antialias=true";
          "XTerm*boldFont" =
            "FiraCode Nerd Font:size=13:style=Bold:antialias=true";
          "XTerm*geometry" = "132x50";
          "XTerm.termName" = "xterm-256color";
          "XTerm*locale" = false;
          "XTerm*utf8" = true;
        };

        fonts.fontconfig = {
          enable = true;
          defaultFonts = {
            serif = [ "Source Serif" "Noto Color Emoji" ];
            sansSerif = [ "Work Sans" "Fira Sans" "Noto Color Emoji" ];
            monospace = [
              "FiraCode Nerd Font Mono"
              "Font Awesome 6 Free"
              "Font Awesome 6 Brands"
              "Symbola"
              "Noto Emoji"
            ];
            emoji = [ "Noto Color Emoji" ];
          };
        };
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
          obsidian

          ## Utility
          dconf-editor
          gnome-disk-utility
          zenity
          wl-clipboard # clipboard utils for wayland (wl-copy, wl-paste)
          gopass-jsonapi

          # fonts
          corefonts
          fira
          fishPlugins.fzf-fish
          font-awesome
          liberation_ttf
          nerd-fonts.fira-code
          nerd-fonts.symbols-only
          nixpkgs-review # Nix code review
          nodePackages.prettier # Code format
          noto-fonts-emoji
          noto-fonts-emoji
          noto-fonts-monochrome-emoji
          source-serif
          symbola
          # joypixels
          ubuntu_font_family
          victor-mono
          work-sans
        ];

      };
  };
  defaultTags = { desktop = lib.mkDefault true; };
}
