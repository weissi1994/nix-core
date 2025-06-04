{ inputs, lib, ... }: {
  apps.desktop-config = {
    tags = [ "desktop" ];
    nixos = { host, pkgs, lib, ... }: {
      hardware = { graphics = { enable = true; }; };
      hardware.enableRedistributableFirmware = true;
      # nixpkgs.config.allowUnfreePredicate = pkg:
      #   builtins.elem (lib.getName pkg) [ "joypixels" ];
      # nixpkgs.config.joypixels.acceptLicense = true;
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
          google-chrome = {
            name = "google-chrome";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data =
                "${lib.getBin pkgs.google-chromer}/share/google/chrome/chrome";
            };
          };
          spotify = {
            name = "spotify";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data =
                "${lib.getBin pkgs.spotify}/share/spotify/.spotify-wrapped";
            };
          };
          telegram = {
            name = "telegram";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${
                  lib.getBin pkgs.telegram-desktop
                }/bin/.telegram-desktop-wrapped";
            };
          };
          networkmanager = {
            name = "networkmanager";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.networkmanager}/bin/NetworkManager";
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
        image = ./files/background.png;

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
        programs.qutebrowser = {
          enable = true;
          keyBindings = {
            normal = {
              "<ctrl+right>" = "tab-next";
              "<ctrl+left>" = "tab-prev";
            };
          };
          settings = {
            auto_save = { session = true; };
            colors = { webpage = { darkmode = { enabled = true; }; }; };
          };
        };
        # programs.warp = {
        #   enable = true;
        #   keybindings = {
        #     "ctrl+shift+up" = "neighboring_window up";
        #     "ctrl+shift+down" = "neighboring_window down";
        #     "ctrl+shift+left" = "neighboring_window left";
        #     "ctrl+shift+right" = "neighboring_window right";
        #     "ctrl+alt+right" = "next_tab";
        #     "ctrl+alt+left" = "previous_tab";
        #     "ctrl+shift+c" = "neighboring_window up";
        #     "ctrl+shift+t" = "neighboring_window down";
        #     "ctrl+shift+h" = "neighboring_window left";
        #     "ctrl+shift+n" = "neighboring_window right";
        #     "ctrl+shift+r" = "next_tab";
        #     "ctrl+shift+g" = "previous_tab";
        #     "ctrl+shift+e" = "new_tab_with_cwd";
        #     "ctrl+shift+o" = "new_tab";
        #     "ctrl+shift+tab" = "next_tab";
        #     "ctrl+tab" = "previous_tab";
        #     "page_up" = "scroll_page_up";
        #     "page_down" = "scroll_page_down";
        #     "ctrl+shift+l" = "show_scrollback";
        #   };
        # };
        programs.wezterm = {
          enable = true;
          extraConfig = ''

            local scrollback_lines = 200000
            local config = wezterm.config_builder()

            -- The filled in variant of the < symbol
            local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider

            -- The filled in variant of the > symbol
            local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

            -- This function returns the suggested title for a tab.
            -- It prefers the title that was set via `tab:set_title()`
            -- or `wezterm cli set-tab-title`, but falls back to the
            -- title of the active pane in that tab.
            function tab_title(tab_info)
              local title = tab_info.tab_title
              -- if the tab title is explicitly set, take that
              if title and #title > 0 then
                return title
              end
              -- Otherwise, use the title from the active pane
              -- in that tab
              return tab_info.active_pane.title
            end

            wezterm.on(
              'format-tab-title',
              function(tab, tabs, panes, config, hover, max_width)
                local edge_background = '#0b0022'
                local background = '#1b1032'
                local foreground = '#808080'

                if tab.is_active then
                  background = '#2b2042'
                  foreground = '#c0c0c0'
                elseif hover then
                  background = '#3b3052'
                  foreground = '#909090'
                end

                local edge_foreground = background

                local title = tab_title(tab)

                -- ensure that the titles fit in the available space,
                -- and that we have room for the edges.
                title = wezterm.truncate_right(title, max_width - 2)

                return {
                  { Background = { Color = edge_background } },
                  { Foreground = { Color = edge_foreground } },
                  { Text = SOLID_LEFT_ARROW },
                  { Background = { Color = background } },
                  { Foreground = { Color = foreground } },
                  { Text = title },
                  { Background = { Color = edge_background } },
                  { Foreground = { Color = edge_foreground } },
                  { Text = SOLID_RIGHT_ARROW },
                }
              end
            )


            config.tab_max_width = 25
            config.text_background_opacity = 1
            config.hide_tab_bar_if_only_one_tab = true
            config.font_size = 11
            config.font = wezterm.font_with_fallback({
              "FiraCode Nerd Font Mono",
              "Noto Color Emoji",
              "MesloLGL Nerd Font",
              "Roboto",
              "Code2000",
              "Symbola",
              "Source Code Pro",
              "Material Icons Two Tone",
              "google-mdi",
              "Unifont",
              "DejaVuSansMono Nerd Font",
              "DejaVu Sans",
              "Droid Sans",
              "Droid Sans Fallback",
              "Unifont",
            })
            config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
            config.window_padding = {
              left = 0,
              right = 0,
              top = 0,
              bottom = 0,
            }
            config.inactive_pane_hsb = {
              saturation = 0.4,
              brightness = 0.6,
            }
            config.tab_bar_at_bottom = true
            config.scrollback_lines = scrollback_lines
            config.default_prog = { "fish" }

            config.keys = {
              { key = "F1", mods = "", action = wezterm.action.ShowTabNavigator },
              { key = ".", mods = "CTRL", action = wezterm.action.PaneSelect },
              { key = "PageUp", mods = "SHIFT", action = wezterm.action.ActivateTabRelative(1) },
              { key = "PageDown", mods = "SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
              { key = "a", mods = "CTRL|SHIFT", action = wezterm.action.ToggleFullScreen },
              {
                key = "Enter",
                mods = "CTRL",
                action = wezterm.action.SpawnTab("CurrentPaneDomain"),
              },
              {
                key = "Enter",
                mods = "CTRL|SHIFT",
                action = wezterm.action.SplitPane({
                  direction = "Down",
                  size = { Percent = 50 },
                }),
              },
              {
                key = "LeftArrow",
                mods = "CTRL|SHIFT",
                action = wezterm.action.SplitPane({
                  direction = "Left",
                  size = { Percent = 50 },
                }),
              },
              {
                key = "DownArrow",
                mods = "CTRL|SHIFT",
                action = wezterm.action.SplitPane({
                  direction = "Down",
                  size = { Percent = 50 },
                }),
              },
              {
                key = "UpArrow",
                mods = "CTRL|SHIFT",
                action = wezterm.action.SplitPane({
                  direction = "Up",
                  size = { Percent = 50 },
                }),
              },
              {
                key = "RightArrow",
                mods = "CTRL|SHIFT",
                action = wezterm.action.SplitPane({
                  direction = "Right",
                  size = { Percent = 50 },
                }),
              },
              {
                key = "LeftArrow",
                mods = "SHIFT",
                action = wezterm.action.ActivatePaneDirection("Left"),
              },
              {
                key = "RightArrow",
                mods = "SHIFT",
                action = wezterm.action.ActivatePaneDirection("Right"),
              },
              {
                key = "UpArrow",
                mods = "SHIFT",
                action = wezterm.action.ActivatePaneDirection("Up"),
              },
              {
                key = "DownArrow",
                mods = "SHIFT",
                action = wezterm.action.ActivatePaneDirection("Down"),
              },
            }

            config.mouse_bindings = {
              {
                event = { Down = { streak = 1, button = "Left" } },
                mods = "CTRL|SHIFT",
                action = wezterm.action.SelectTextAtMouseCursor("Block"),
              },
              {
                event = { Drag = { streak = 1, button = "Left" } },
                mods = "CTRL|SHIFT",
                action = wezterm.action.ExtendSelectionToMouseCursor("Block"),
              },
              {
                event = { Up = { streak = 1, button = "Left" } },
                mods = "CTRL|SHIFT",
                action = wezterm.action.CompleteSelection("ClipboardAndPrimarySelection"),
              },
              {
                event = { Down = { streak = 1, button = 'Right' } },
                action = wezterm.action.Multiple {
                  { SelectTextAtMouseCursor = 'SemanticZone' },
                  { CopyTo = 'ClipboardAndPrimarySelection' },
                },
                mods = 'NONE',
              },
            }

            return config
          '';
        };
        programs.kitty = {
          enable = true;
          shellIntegration = {
            mode = "no-sudo";
  
