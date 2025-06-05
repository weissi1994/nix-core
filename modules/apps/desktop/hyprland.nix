{ inputs, lib, ... }: {
  apps.hyprland-config = {
    tags = [ "desktop" ];
    enablePredicate = { host, ... }: host.desktop == "hyprland";

    nixos = { host, pkgs, ... }: { programs.hyprland.enable = true; };

    home = { host, pkgs, ... }:
      let
        colors = {
          base00 = "#1e1e2e"; # base
          base01 = "#181825"; # mantle
          base02 = "#313244"; # surface0
          base03 = "#45475a"; # surface1
          base04 = "#585b70"; # surface2
          base05 = "#cdd6f4"; # text
          base06 = "#f5e0dc"; # rosewater
          base07 = "#b4befe"; # lavender
          base08 = "#f38ba8"; # red
          base09 = "#fab387"; # peach
          base0A = "#f9e2af"; # yellow
          base0B = "#a6e3a1"; # green
          base0C = "#94e2d5"; # teal
          base0D = "#89b4fa"; # blue
          base0E = "#cba6f7"; # mauve
          base0F = "#f2cdcd"; # flamingo
        };
        terminal = "kitty";
        browser = "google-chrome";
        background = ../files/background.png;
        profile = ../files/face.png;
      in {
        home.packages = with pkgs; [
          grim
          slurp
          wl-clipboard
          swappy
          ydotool
          hyprpolkitagent
          hyprland-qtutils # needed for banners and ANR messages
          pyprland
        ];
        systemd.user.targets.hyprland-session.Unit.Wants =
          [ "xdg-desktop-autostart.target" ];
        # Place Files Inside Home Directory
        home.file = {
          ".face.icon".source = ../files/face.png;
          ".config/face.jpg".source = ../files/face.png;
          ".config/background.png".source = ../files/background.png;
        };

        wayland.windowManager.hyprland = {
          enable = true;
          package = pkgs.hyprland;
          systemd = {
            enable = true;
            enableXdgAutostart = true;
            variables = [ "--all" ];
          };
          xwayland = { enable = true; };

          extraConfig =
            "\n      monitor=,preferred,auto,auto\n      monitor=eDP-1,1920x1080@60,auto,1\n      # To enable blur on waybar uncomment the line below\n      # Thanks to SchotjeChrisman\n      #layerrule = blur,waybar\n    ";
          settings = {
            exec-once = [
              "wl-paste --type text --watch cliphist store # Stores only text data"
              "wl-paste --type image --watch cliphist store # Stores only image data"
              "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
              "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
              "systemctl --user restart hyprpolkitagent"
              "systemctl --user restart opensnitch-ui"
              "systemctl --user restart nm-applet"
              "systemctl --user restart swaync"
              "systemctl --user restart waybar"
              "killall -q swww;sleep .5 && swww init"
              # "killall -q waybar;sleep .5 && waybar"
              # "killall -q swaync;sleep .5 && swaync"
              # "nm-applet --indicator"
              "pypr &"
              "obsidian &"
              "spotify &"
              "google-chrome-stable &"
              "telegram-desktop &"
              "discord &"
              "sleep 1.5 && swww img /home/${host.username}/.config/background.png"
            ];
            input = {
              kb_layout = "us";
              kb_options = [ "altgr-intl" ];
              numlock_by_default = true;
              repeat_delay = 300;
              follow_mouse = 1;
              float_switch_override_focus = 0;
              sensitivity = 0;
              touchpad = {
                natural_scroll = true;
                disable_while_typing = true;
                scroll_factor = 0.8;
              };
            };
            gestures = {
              workspace_swipe = 1;
              workspace_swipe_fingers = 3;
              workspace_swipe_distance = 500;
              workspace_swipe_invert = 1;
              workspace_swipe_min_speed_to_force = 30;
              workspace_swipe_cancel_ratio = 0.5;
              workspace_swipe_create_new = 1;
              workspace_swipe_forever = 1;
            };
            general = {
              "$modifier" = "SUPER";
              layout = "dwindle";
              gaps_in = 6;
              gaps_out = 8;
              border_size = 2;
              resize_on_border = true;
              "col.active_border" = "rgb(f38ba8) rgb(94e2d5) 45deg";
              "col.inactive_border" = "rgb(181825)";
            };

            misc = {
              layers_hog_keyboard_focus = true;
              initial_workspace_tracking = 0;
              mouse_move_enables_dpms = true;
              key_press_enables_dpms = false;
              disable_hyprland_logo = true;
              disable_splash_rendering = true;
              enable_swallow = false;
              vfr = true; # Variable Frame Rate
              vrr =
                2; # Variable Refresh Rate  Might need to set to 0 for NVIDIA/AQ_DRM_DEVICES
              # Screen flashing to black momentarily or going black when app is fullscreen
              # Try setting vrr to 0

              #  Application not responding (ANR) settings
              enable_anr_dialog = true;
              anr_missed_pings = 20;
            };

            dwindle = {
              pseudotile = true;
              preserve_split = true;
              force_split = 2;
            };

            decoration = {
              rounding = 10;
              blur = {
                enabled = true;
                size = 5;
                passes = 3;
                ignore_opacity = false;
                new_optimizations = true;
              };
              shadow = {
                enabled = true;
                range = 4;
                render_power = 3;
                color = "rgba(1a1a1aee)";
              };
            };

            ecosystem = {
              no_donation_nag = true;
              no_update_news = false;
            };

            cursor = {
              sync_gsettings_theme = true;
              no_hardware_cursors = 2; # change to 1 if want to disable
              enable_hyprcursor = false;
              warp_on_change_workspace = 2;
              no_warps = true;
            };

            render = {
              explicit_sync = 1; # Change to 1 to disable
              explicit_sync_kms = 1;
              direct_scanout = 0;
            };

            master = {
              new_status = "master";
              new_on_top = 1;
              mfact = 0.5;
            };

            windowrulev2 = [
              "tag +file-manager, class:^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$"
              "tag +terminal, class:^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty|kitty-dropterm)$"
              "tag +browser, class:^(Brave-browser(-beta|-dev|-unstable)?)$"
              "tag +browser, class:^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$"
              "tag +browser, class:^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$"
              "tag +browser, class:^([Tt]horium-browser|[Cc]achy-browser)$"
              "tag +projects, class:^(codium|codium-url-handler|VSCodium)$"
              "tag +projects, class:^(VSCode|code-url-handler)$"
              "tag +im, class:^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$"
              "tag +im, class:^([Ff]erdium)$"
              "tag +im, class:^([Ww]hatsapp-for-linux)$"
              "tag +im, class:^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$"
              "tag +im, class:^(teams-for-linux)$"
              "tag +games, class:^(gamescope)$"
              "tag +games, class:^(steam_app_d+)$"
              "tag +gamestore, class:^([Ss]team)$"
              "tag +gamestore, title:^([Ll]utris)$"
              "tag +gamestore, class:^(com.heroicgameslauncher.hgl)$"
              "tag +settings, class:^(gnome-disks|wihotspot(-gui)?)$"
              "tag +settings, class:^([Rr]ofi)$"
              "tag +settings, class:^(file-roller|org.gnome.FileRoller)$"
              "tag +settings, class:^(nm-applet|nm-connection-editor|blueman-manager)$"
              "tag +settings, class:^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"
              "tag +settings, class:^(nwg-look|qt5ct|qt6ct|[Yy]ad)$"
              "tag +settings, class:(xdg-desktop-portal-gtk)"
              "tag +settings, class:(.blueman-manager-wrapped)"
              "tag +settings, class:(nwg-displays)"
              "move 72% 7%,title:^(Picture-in-Picture)$"
              "center, class:^([Ff]erdium)$"
              "float, class:^([Ww]aypaper)$"
              "center, class:^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"
              "center, class:([Tt]hunar), title:negative:(.*[Tt]hunar.*)"
              "center, title:^(Authentication Required)$"
              "idleinhibit fullscreen, class:^(*)$"
              "idleinhibit fullscreen, title:^(*)$"
              "idleinhibit fullscreen, fullscreen:1"
              "float, tag:settings*"
              "float, class:^([Ff]erdium)$"
              "float, title:^(Picture-in-Picture)$"
              "float, class:^(mpv|com.github.rafostar.Clapper)$"
              "float, title:^(Authentication Required)$"
              "float, class:(codium|codium-url-handler|VSCodium), title:negative:(.*codium.*|.*VSCodium.*)"
              "float, class:^(com.heroicgameslauncher.hgl)$, title:negative:(Heroic Games Launcher)"
              "float, class:^(blueman-manager|opensnitch_ui)$"
              "float, class:^([Ss]team)$, title:negative:^([Ss]team)$"
              "float, class:([Tt]hunar), title:negative:(.*[Tt]hunar.*)"
              "float, initialTitle:(Add Folder to Workspace)"
              "float, initialTitle:(Open Files)"
              "float, initialTitle:(wants to save)"
              "size 70% 60%, initialTitle:(Open Files)"
              "size 70% 60%, initialTitle:(Add Folder to Workspace)"
              "size 70% 70%, tag:settings*"
              "size 60% 70%, class:^([Ff]erdium)$"
              "opacity 1.0 1.0, tag:browser*"
              "opacity 0.9 0.8, tag:projects*"
              "opacity 0.94 0.86, tag:im*"
              "opacity 0.9 0.8, tag:file-manager*"
              "opacity 0.8 0.7, tag:terminal*"
              "opacity 0.8 0.7, tag:settings*"
              "opacity 0.8 0.7, class:^(gedit|org.gnome.TextEditor|mousepad)$"
              "opacity 0.9 0.8, class:^(seahorse)$ # gnome-keyring gui"
              "opacity 0.95 0.75, title:^(Picture-in-Picture)$"
              "pin, title:^(Picture-in-Picture)$"
              "keepaspectratio, title:^(Picture-in-Picture)$"
              "noblur, tag:games*"
              "fullscreen, tag:games*"
            ];
            bind = [
              "$modifier,Return,exec,${terminal}"
              "$modifier SHIFT,K,exec,list-keybinds"
              "$modifier SHIFT,Return,exec,rofi-launcher"
              "$modifier SHIFT,N,exec,swaync-client -rs"
              "$modifier,G,exec,${browser}"
              "$modifier,n,exec,kitty -e yazi"
              "$modifier,T,exec,pypr toggle term"
              "$modifier SHIFT,Q,killactive,"
              "$modifier,v,exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
              "$modifier SHIFT,I,togglesplit,"
              "$modifier,F,fullscreen,"
              "$modifier SHIFT,F,togglefloating,"
              "$modifier ALT,F,workspaceopt, allfloat"
              "$modifier SHIFT,C,exit,"
              "$modifier SHIFT,left,movewindow,l"
              "$modifier SHIFT,right,movewindow,r"
              "$modifier SHIFT,up,movewindow,u"
              "$modifier SHIFT,down,movewindow,d"
              "$modifier SHIFT,h,movewindow,l"
              "$modifier SHIFT,l,movewindow,r"
              "$modifier SHIFT,k,movewindow,u"
              "$modifier SHIFT,j,movewindow,d"
              "$modifier ALT, left, swapwindow,l"
              "$modifier ALT, right, swapwindow,r"
              "$modifier ALT, up, swapwindow,u"
              "$modifier ALT, down, swapwindow,d"
              "$modifier ALT, 43, swapwindow,l"
              "$modifier ALT, 46, swapwindow,r"
              "$modifier ALT, 45, swapwindow,u"
              "$modifier ALT, 44, swapwindow,d"
              "$modifier,left,movefocus,l"
              "$modifier,right,movefocus,r"
              "$modifier,up,movefocus,u"
              "$modifier,down,movefocus,d"
              "$modifier,h,movefocus,l"
              "$modifier,l,movefocus,r"
              "$modifier,k,movefocus,u"
              "$modifier,j,movefocus,d"
              "$modifier,1,workspace,1"
              "$modifier,2,workspace,2"
              "$modifier,3,workspace,3"
              "$modifier,4,workspace,4"
              "$modifier,5,workspace,5"
              "$modifier,6,workspace,6"
              "$modifier,7,workspace,7"
              "$modifier,8,workspace,8"
              "$modifier,9,workspace,9"
              "$modifier,0,workspace,10"
              "$modifier SHIFT,SPACE,movetoworkspace,special"
              "$modifier,SPACE,togglespecialworkspace"
              "$modifier SHIFT,1,movetoworkspace,1"
              "$modifier SHIFT,2,movetoworkspace,2"
              "$modifier SHIFT,3,movetoworkspace,3"
              "$modifier SHIFT,4,movetoworkspace,4"
              "$modifier SHIFT,5,movetoworkspace,5"
              "$modifier SHIFT,6,movetoworkspace,6"
              "$modifier SHIFT,7,movetoworkspace,7"
              "$modifier SHIFT,8,movetoworkspace,8"
              "$modifier SHIFT,9,movetoworkspace,9"
              "$modifier SHIFT,0,movetoworkspace,10"
              "$modifier CONTROL,right,workspace,e+1"
              "$modifier CONTROL,left,workspace,e-1"
              "$modifier,mouse_down,workspace, e+1"
              "$modifier,mouse_up,workspace, e-1"
              "ALT,Tab,cyclenext"
              "ALT,Tab,bringactivetotop"
              ",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
              ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
              " ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
              ",XF86AudioPlay, exec, playerctl play-pause"
              ",XF86AudioPause, exec, playerctl play-pause"
              ",XF86AudioNext, exec, playerctl next"
              ",XF86AudioPrev, exec, playerctl previous"
              ",XF86MonBrightnessDown,exec,brightnessctl set 5%-"
              ",XF86MonBrightnessUp,exec,brightnessctl set +5%"
            ];

            bindm = [
              "$modifier, mouse:272, movewindow"
              "$modifier, mouse:273, resizewindow"
            ];
            # Name: END-4
            # Credit: END-4 project https://github.com/end-4/dots-hyprland
            animations = {
              enabled = true;
              bezier = [
                "linear, 0, 0, 1, 1"
                "md3_standard, 0.2, 0, 0, 1"
                "md3_decel, 0.05, 0.7, 0.1, 1"
                "md3_accel, 0.3, 0, 0.8, 0.15"
                "overshot, 0.05, 0.9, 0.1, 1.1"
                "crazyshot, 0.1, 1.5, 0.76, 0.92 "
                "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
                "menu_decel, 0.1, 1, 0, 1"
                "menu_accel, 0.38, 0.04, 1, 0.07"
                "easeInOutCirc, 0.85, 0, 0.15, 1"
                "easeOutCirc, 0, 0.55, 0.45, 1"
                "easeOutExpo, 0.16, 1, 0.3, 1"
                "softAcDecel, 0.26, 0.26, 0.15, 1"
                "md2, 0.4, 0, 0.2, 1 # use with .2s duration"
              ];
              animation = [
                "windows, 1, 3, md3_decel, popin 60%"
                "windowsIn, 1, 3, md3_decel, popin 60%"
                "windowsOut, 1, 3, md3_accel, popin 60%"
                "border, 1, 10, default"
                "fade, 1, 3, md3_decel"
                "layersIn, 1, 3, menu_decel, slide"
                "layersOut, 1, 1.6, menu_accel"
                "fadeLayersIn, 1, 2, menu_decel"
                "fadeLayersOut, 1, 4.5, menu_accel"
                "workspaces, 1, 7, menu_decel, slide"
              ];
            };
            env = [
              "NIXOS_OZONE_WL, 1"
              "NIXPKGS_ALLOW_UNFREE, 1"
              "XDG_CURRENT_DESKTOP, Hyprland"
              "XDG_SESSION_TYPE, wayland"
              "XDG_SESSION_DESKTOP, Hyprland"
              "GDK_BACKEND, wayland, x11"
              "CLUTTER_BACKEND, wayland"
              "QT_QPA_PLATFORM=wayland;xcb"
              "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
              "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
              "SDL_VIDEODRIVER, x11"
              "MOZ_ENABLE_WAYLAND, 1"
              "AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
              "GDK_SCALE,1"
              "QT_SCALE_FACTOR,1"
              "EDITOR,nvim"
            ];
          };
        };

        home.file.".config/hypr/pyprland.toml".text = ''
          [pyprland]
          plugins = [
            "scratchpads",
          ]

          [scratchpads.term]
          animation = "fromTop"
          command = "kitty --class kitty-dropterm"
          class = "kitty-dropterm"
          size = "70% 70%"
          max_size = "1920px 100%"
          position = "150px 150px"
        '';
        programs.hyprlock = {
          enable = true;
          settings = {
            general = {
              disable_loading_bar = true;
              grace = 10;
              hide_cursor = true;
              no_fade_in = false;
            };
            background = [{
              path = "/home/${host.username}/.config/background.png";
              blur_passes = 3;
              blur_size = 8;
            }];
            image = [{
              path = "/home/${host.username}/.config/face.png";
              size = 150;
              border_size = 4;
              border_color = "rgb(0C96F9)";
              rounding = -1; # Negative means circle
              position = "0, 200";
              halign = "center";
              valign = "center";
            }];
            input-field = [{
              size = "200, 50";
              position = "0, -80";
              monitor = "";
              dots_center = true;
              fade_on_empty = false;
              font_color = "rgb(CFE6F4)";
              inner_color = "rgb(657DC2)";
              outer_color = "rgb(0D0E15)";
              outline_thickness = 5;
              placeholder_text = "Password...";
              shadow_passes = 2;
            }];
          };
        };
        programs = {
          rofi = {
            enable = true;
            package = pkgs.rofi-wayland;
            extraConfig = {
              modi = "drun,filebrowser,run";
              show-icons = true;
              icon-theme = "Papirus";
              font = "JetBrainsMono Nerd Font Mono 12";
              drun-display-format = "{icon} {name}";
              display-drun = " Apps";
              display-run = " Run";
              display-filebrowser = " File";
            };
            theme = with colors; {
              "*" = {
                bg = "${base00}";
                bg-alt = "${base09}";
                foreground = "${base01}";
                selected = "${base08}";
                active = "${base0B}";
                text-selected = "${base00}";
                text-color = "${base05}";
                border-color = "${base0F}";
                urgent = "${base0E}";
              };
              "window" = {
                transparency = "real";
                width = "1000px";
                location = "center";
                anchor = "center";
                fullscreen = false;
                x-offset = "0px";
                y-offset = "0px";
                cursor = "default";
                enabled = true;
                border-radius = "15px";
                background-color = "@bg";
              };
              "mainbox" = {
                enabled = true;
                spacing = "0px";
                orientation = "horizontal";
                children = map [ "imagebox" "listbox" ];
                background-color = "transparent";
              };
              "imagebox" = {
                padding = "20px";
                background-color = "transparent";
                background-image = ''url("~/.config/background.png", height)'';
                orientation = "vertical";
                children = map [ "inputbar" "dummy" "mode-switcher" ];
              };
              "listbox" = {
                spacing = "20px";
                padding = "20px";
                background-color = "transparent";
                orientation = "vertical";
                children = map [ "message" "listview" ];
              };
              "dummy" = { background-color = "transparent"; };
              "inputbar" = {
                enabled = true;
                spacing = "10px";
                padding = "10px";
                border-radius = "10px";
                background-color = "@bg-alt";
                text-color = "@foreground";
                children = map [ "textbox-prompt-colon" "entry" ];
              };
              "textbox-prompt-colon" = {
                enabled = true;
                expand = false;
                str = "";
                background-color = "inherit";
                text-color = "inherit";
              };
              "entry" = {
                enabled = true;
                background-color = "inherit";
                text-color = "inherit";
                cursor = "text";
                placeholder = "Search";
                placeholder-color = "inherit";
              };
              "mode-switcher" = {
                enabled = true;
                spacing = "20px";
                background-color = "transparent";
                text-color = "@foreground";
              };
              "button" = {
                padding = "15px";
                border-radius = "10px";
                background-color = "@bg-alt";
                text-color = "inherit";
                cursor = "pointer";
              };
              "button selected" = {
                background-color = "@selected";
                text-color = "@foreground";
              };
              "listview" = {
                enabled = true;
                columns = 1;
                lines = 8;
                cycle = true;
                dynamic = true;
                scrollbar = false;
                layout = "vertical";
                reverse = false;
                fixed-height = true;
                fixed-columns = true;
                spacing = "10px";
                background-color = "transparent";
                text-color = "@foreground";
                cursor = "default";
              };
              "element" = {
                enabled = true;
                spacing = "15px";
                padding = "8px";
                border-radius = "10px";
                background-color = "transparent";
                text-color = "@text-color";
                cursor = "pointer";
              };
              "element normal.normal" = {
                background-color = "inherit";
                text-color = "@text-color";
              };
              "element normal.urgent" = {
                background-color = "@urgent";
                text-color = "@text-color";
              };
              "element normal.active" = {
                background-color = "inherit";
                text-color = "@text-color";
              };
              "element selected.normal" = {
                background-color = "@selected";
                text-color = "@foreground";
              };
              "element selected.urgent" = {
                background-color = "@urgent";
                text-color = "@text-selected";
              };
              "element selected.active" = {
                background-color = "@urgent";
                text-color = "@text-selected";
              };
              "element-icon" = {
                background-color = "transparent";
                text-color = "inherit";
                size = "36px";
                cursor = "inherit";
              };
              "element-text" = {
                background-color = "transparent";
                text-color = "inherit";
                cursor = "inherit";
                vertical-align = "0.5";
                horizontal-align = "0.0";
              };
              "message" = { background-color = "transparent"; };
              "textbox" = {
                padding = "15px";
                border-radius = "10px";
                background-color = "@bg-alt";
                text-color = "@foreground";
                vertical-align = "0.5";
                horizontal-align = "0.0";
              };
              "error-message" = {
                padding = "15px";
                border-radius = "20px";
                background-color = "@bg";
                text-color = "@foreground";
              };
            };
          };
        };
        services = {
          hypridle = {
            enable = true;
            settings = {
              general = {
                after_sleep_cmd = "hyprctl dispatch dpms on";
                ignore_dbus_inhibit = false;
                lock_cmd = "hyprlock";
              };
              listener = [
                {
                  timeout = 900;
                  on-timeout = "hyprlock";
                }
                {
                  timeout = 1200;
                  on-timeout = "hyprctl dispatch dpms off";
                  on-resume = "hyprctl dispatch dpms on";
                }
              ];
            };
          };
        };

      };
  };
}
