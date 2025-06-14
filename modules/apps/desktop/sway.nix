{ inputs, lib, ... }: {
  apps.sway-config = {
    tags = [ "desktop" ];
    enablePredicate = { host, ... }: host.desktop == "sway";

    nixos = { host, pkgs, ... }: {
      # enable sway window manager
      programs.sway = {
        enable = true;
        wrapperFeatures.base = true;
        wrapperFeatures.gtk = true; # so that gtk works properly
        extraPackages = with pkgs; [
          adwaita-icon-theme # default gnome cursors
          birdtray # email tray
          brightnessctl
          dmenu
          dmenu-wayland
          dracula-theme # gtk theme (dark)
          evince
          feh
          foot # default terminal (for iso)
          gammastep # make it red at night!
          gimp
          glib # gsettings
          gnome-system-monitor
          himalaya
          kanshi # autorandr
          libappindicator
          mate.caja
          nautilus
          nemo
          notify-desktop
          nwg-launchers
          swayidle
          swaylock # lockscreen
          swaylock-effects
          swaynotificationcenter # notification daemon
          swayr
          tesseract4
          wl-clipboard
          wofi
          wofi-emoji
          xwayland # for legacy apps
          ydiff
          yubioath-flutter
          zenity
        ];
      };
    };

    home = { host, pkgs, config, ... }:
      let
        modifier = "Mod4";
        left = "Left";
        down = "Down";
        up = "Up";
        right = "Right";
        resizeAmount = "30px";
        menu = "nwggrid -b '#060708'";
        filebrowser = "nemo";
        webbrowser = "brave";
        webbrowserPersistent = "google-chrome-stable";
        musicplayer = "spotify";
        background = ../files/background.png;
      in {
        home = {
          file = {
            ".config/sway/idle.sh".source = ../files/sway/idle.sh;
            ".config/sway/color-picker.sh".source = builtins.fetchurl {
              url =
                "https://raw.githubusercontent.com/jgmdev/wl-color-picker/main/wl-color-picker.sh";
              sha256 = "0f3i86q9vx0665h2wvmmnfccd85kav4d9kinfzdnqpnh96iqsjkg";
            };
            ".config/sway/lock.sh".source = ../files/sway/lock.sh;
            ".config/nwg-launchers/nwgbar/images/system-reboot.svg".source =
              ../files/sway/system-reboot.svg;
            ".config/nwg-launchers/nwgbar/images/system-log-out.svg".source =
              ../files/sway/system-log-out.svg;
            ".config/nwg-launchers/nwgbar/images/system-suspend.svg".source =
              ../files/sway/system-suspend.svg;
            ".config/nwg-launchers/nwgbar/images/system-shutdown.svg".source =
              ../files/sway/system-shutdown.svg;
            ".config/nwg-launchers/nwgbar/images/system-hibernate.svg".source =
              ../files/sway/system-hibernate.svg;
            ".config/nwg-launchers/nwgbar/images/system-lock-screen.svg".source =
              ../files/sway/system-lock-screen.svg;
          };
        };
        wayland.windowManager.sway = {
          enable = true;
          extraOptions = [ "--unsupported-gpu" ];
          systemd.enable = true;
          systemd.xdgAutostart = true;
          wrapperFeatures.base = true;
          wrapperFeatures.gtk = true;
          # extraSessionCommands = ''
          #   export _JAVA_AWT_WM_NONREPARENTING=1
          #   export GTK_THEME='Catppuccin-Mocha-Compact-Blue-Dark:dark'
          #   export QT_AUTO_SCREEN_SCALE_FACTOR=1
          #   export QT_QPA_PLATFORM=wayland
          #   export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
          #   export GDK_BACKEND=wayland
          #   export XDG_CURRENT_DESKTOP=sway
          #   export WLR_RENDERER=vulkan
          #   export WLR_NO_HARDWARE_CURSORS=1
          #   export XWAYALND_NO_GLAMOR=1
          # '';
          config = {
            output = { "*" = { bg = "${background} fill"; }; };
            gaps = {
              inner = 2;
              smartBorders = "on";
              smartGaps = true;
            };
            floating.border = 1;
            window.border = 1;
            bars = [{ command = "waybar"; }];
            fonts = {
              names = [
                "FiraCode Nerd Font"
                "Noto Color Emoji"
                "Font Awesome 6 Free"
                "Roboto"
              ];
              style = "Regular Bold";
              # size = 12.0;
            };
            input = {
              "type:keyboard" = {
                xkb_layout = lib.mkDefault "us";
                xkb_variant = lib.mkDefault "altgr-intl";
              };
            };
            inherit menu;
            inherit modifier;
            inherit left;
            inherit down;
            inherit up;
            inherit right;
            keybindings = {
              # Exit sway (logs you out of your Wayland session)
              "${modifier}+Shift+e" =
                "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";
              # Reload the configuration file
              "${modifier}+Shift+r" = "reload";
              # Kill focused window
              "${modifier}+Shift+q" = "kill";
              "${modifier}+a" = "exec sh .config/sway/lock.sh";
              "${modifier}+d" = "exec ${menu}";
              "${modifier}+Escape" = "exec ${menu}";
              # Launch the default terminal. $TERM is defined in ../alacritty.nix line 11
              "${modifier}+Return" = "exec kitty";
              "${modifier}+Shift+Return" = "exec wezterm";
              # Take a screenshot by selecting an area
              "print" = "exec sh $HOME/.config/screenshot.sh active";
              "Shift+print" = "exec sh $HOME/.config/screenshot.sh output";
              "${modifier}+print" =
                "exec sh $HOME/.config/screenshot.sh screen";
              "${modifier}+b" = "exec ${filebrowser}";
              "${modifier}+Shift+g" = "exec ${webbrowser}";
              "${modifier}+g" = "exec ${webbrowserPersistent}";
              "${modifier}+m" = "exec ${musicplayer}";
              # Toggle deafen
              "XF86AudioMute" =
                "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
              # Toggle mute
              "XF86AudioMute+Ctrl" =
                "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle && ffmpeg -y -f lavfi -i 'sine=frequency=200:duration=0.1' /tmp/sound.ogg && play /tmp/sound.ogg";
              # Raise sink (speaker, headphones) volume
              "XF86AudioRaiseVolume" =
                "exec pactl set-sink-volume @DEFAULT_SINK@ +2%";
              # Lower sink (microphone) volume
              "XF86AudioLowerVolume" =
                "exec pactl set-sink-volume @DEFAULT_SINK@ -2%";
              # Spotify
              ## Play/pause spotify
              "XF86AudioPlay" =
                "exec dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause";
              ## Play previous spotify track
              "XF86AudioPrev" =
                "exec dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous";
              "XF86Launch5" =
                "exec dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous";
              ## Play next spotify track
              "XF86AudioNext" =
                "exec dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next";
              "XF86Tools" =
                "exec dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next";

              # Moving around
              ## Move your focus around
              "${modifier}+${left}" = "focus left";
              "${modifier}+${down}" = "focus down";
              "${modifier}+${up}" = "focus up";
              "${modifier}+${right}" = "focus right";
              ## Move the focused window with the same, but add Shift
              "${modifier}+Shift+${left}" = "move left";
              "${modifier}+Shift+${down}" = "move down";
              "${modifier}+Shift+${up}" = "move up";
              "${modifier}+Shift+${right}" = "move right";
              ## Move your focus around
              "${modifier}+h" = "focus left";
              "${modifier}+t" = "focus down";
              "${modifier}+c" = "focus up";
              "${modifier}+n" = "focus right";
              ## Move the focused window with the same, but add Shift
              "${modifier}+Shift+h" = "move left";
              "${modifier}+Shift+t" = "move down";
              "${modifier}+Shift+c" = "move up";
              "${modifier}+Shift+n" = "move right";
              # Workspaces
              ## Switch to workspace
              "${modifier}+1" = "workspace number 1";
              "${modifier}+2" = "workspace number 2";
              "${modifier}+3" = "workspace number 3";
              "${modifier}+4" = "workspace number 4";
              "${modifier}+5" = "workspace number 5";
              "${modifier}+6" = "workspace number 6";
              "${modifier}+7" = "workspace number 7";
              "${modifier}+8" = "workspace number 8";
              "${modifier}+9" = "workspace number 9";
              "${modifier}+0" = "workspace number 10";
              ## Move focused container to workspace
              "${modifier}+Shift+1" = "move container to workspace number 1";
              "${modifier}+Shift+2" = "move container to workspace number 2";
              "${modifier}+Shift+3" = "move container to workspace number 3";
              "${modifier}+Shift+4" = "move container to workspace number 4";
              "${modifier}+Shift+5" = "move container to workspace number 5";
              "${modifier}+Shift+6" = "move container to workspace number 6";
              "${modifier}+Shift+7" = "move container to workspace number 7";
              "${modifier}+Shift+8" = "move container to workspace number 8";
              "${modifier}+Shift+9" = "move container to workspace number 9";
              "${modifier}+Shift+0" = "move container to workspace number 10";
              ## Workspaces can have any name you want, not just numbers.
              ## We just use 1-10 as the default.
              # Layout stuff
              ## You can "split" the current object of your focus with ${modifier}+b, ${modifier}+v for horizontal and vertical splits respectively.
              "${modifier}+q" = "splith";
              "${modifier}+j" = "splitv";
              ## Switch the current container between different layout styles
              "${modifier}+s" = "layout stacking";
              "${modifier}+w" = "layout tabbed";
              "${modifier}+e" = "layout toggle split";
              ## Make the current focus fullscreen
              "${modifier}+f" = "fullscreen";
              ## Toggle the current focus between tiling and floating mode
              "${modifier}+Shift+space" = "floating toggle";
              ## Swap focus between the tiling area and the floating area
              "${modifier}+space" = "focus mode_toggle";
              ## Move focus to the parent container
              "${modifier}+p" = "focus parent";
              # Scratchpad
              ## Sway has a "scratchpad", which is a bag of holding for windows. You can send windows there and get them back later.
              ## Move the currently focused window to the scratchpad
              "${modifier}+Shift+minus" = "move scratchpad";
              ## Show the next scratchpad window or hide the focused scratchpad window. If there are multiple scratchpad windows, this command cycles through them.
              "${modifier}+minus" = "scratchpad show";
              # Resizing containers
              # Mode "resize"
              "${modifier}+r" = "mode 'resize'";
              # Mode "resize"
              "${modifier}+x" = "exec nwgbar -b '#060708'";
            };
            modes = {
              resize = {
                # left will shrink the containers width
                # right will grow the containers width
                # up will shrink the containers height
                # down will grow the containers height
                "${modifier}+${left}" = "resize shrink width ${resizeAmount}";
                "${modifier}+${down}" = "resize grow height ${resizeAmount}";
                "${modifier}+${up}" = "resize shrink height ${resizeAmount}";
                "${modifier}+${right}" = "resize grow width ${resizeAmount}";
                "${modifier}+h" = "resize shrink width ${resizeAmount}";
                "${modifier}+j" = "resize grow height ${resizeAmount}";
                "${modifier}+k" = "resize shrink height ${resizeAmount}";
                "${modifier}+l" = "resize grow width ${resizeAmount}";
                # Return to default mode
                "Return" = "mode 'default'";
                "Escape" = "mode 'default'";
              };
            };
            startup = [
              # Note taking app
              {
                command = "obsidian";
              }
              # Notification daemon
              {
                command = "swaync";
              }
              # Spotify
              {
                command = "spotify";
              }
              # Web browsing
              {
                command = "google-chrome-stable";
              }
              # Chatting
              {
                command = "telegram-desktop";
              }
              # Chatting
              {
                command = "discord";
              }
              # Polkit
              {
                command =
                  "/run/current-system/sw/libexec/polkit-gnome-authentication-agent-1";
              }
              # Idle
              {
                command = "$HOME/.config/sway/idle.sh";
              }
              # Network Manager
              { command = "nm-applet --indicator"; }
            ];
            terminal = pkgs.kitty;
            window.titlebar = false;
            workspaceAutoBackAndForth = true;
          };
          extraConfig = ''
            for_window [urgent="latest"] focus
            focus_on_window_activation   focus
            focus_follows_mouse yes

            # Make the terminal floating and always on bottom
            for_window [app_id="cava-bg"] floating enable
            for_window [app_id="cava-bg"] resize set 2560 1440  # Adjust for your resolution
            for_window [app_id="cava-bg"] move position 0 0
            for_window [app_id="cava-bg"] focus disable
            for_window [app_id="cava-bg"] border none

            for_window [app_id="(?i)(?:pavucontrol|nm-connection-editor|gsimplecal|galculator)"] floating enable
            for_window [app_id="(?i)(?:firefox|chromium)"] border none
            for_window [title="(?i)(?:copying|deleting|moving)"] floating enable

            popup_during_fullscreen smart
          '';
        };

        gtk = {
          enable = true;
          # theme = {
          #   name = lib.mkForce "Catppuccin-Mocha-Compact-Blue-Dark";
          #   package = lib.mkForce pkgs.catppuccin-gtk;
          # };
          # iconTheme = {
          #   package = pkgs.adwaita-icon-theme;
          #   name = "adwaita";
          # };
        };

      };
  };
}
