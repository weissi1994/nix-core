{ inputs, lib, ... }: {
  apps.waybar-config = {
    tags = [ "desktop" ];
    enablePredicate = { host, ... }:
      host.desktop == "waybar" || host.desktop == "hyprland";

    nixos = { host, pkgs, ... }: { };

    home = { host, pkgs, config, ... }: {
      programs.waybar = {
        enable = true;
        package = pkgs.waybar;
        settings = [{
          layer = "top";
          position = "top";
          modules-center = [ "hyprland/workspaces" ];
          modules-left = [
            "custom/startmenu"
            "custom/arrow6"
            "pulseaudio"
            "cpu"
            "memory"
            "idle_inhibitor"
            "custom/arrow7"
            "hyprland/window"
          ];
          modules-right = [
            "custom/arrow4"
            "custom/hyprbindings"
            "custom/arrow3"
            "custom/notification"
            "custom/arrow3"
            "custom/exit"
            "battery"
            "custom/arrow2"
            "tray"
            "custom/arrow1"
            "clock"
          ];

          "hyprland/workspaces" = {
            format = "{name}";
            format-icons = {
              default = " ";
              active = " ";
              urgent = " ";
            };
            on-scroll-up = "hyprctl dispatch workspace e+1";
            on-scroll-down = "hyprctl dispatch workspace e-1";
          };
          "clock" = {
            format = " {:L%H:%M}";
            tooltip = true;
            tooltip-format = ''
              <big>{:%A, %d.%B %Y }</big>
              <tt><small>{calendar}</small></tt>'';
          };
          "hyprland/window" = {
            max-length = 22;
            separate-outputs = false;
            rewrite = { "" = " 🙈 No Windows? "; };
          };
          "memory" = {
            interval = 5;
            format = " {}%";
            tooltip = true;
          };
          "cpu" = {
            interval = 5;
            format = " {usage:2}%";
            tooltip = true;
          };
          "disk" = {
            format = " {free}";
            tooltip = true;
          };
          "network" = {
            format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
            format-ethernet = " {bandwidthDownOctets}";
            format-wifi = "{icon} {signalStrength}%";
            format-disconnected = "󰤮";
            tooltip = false;
          };
          "tray" = { spacing = 12; };
          "pulseaudio" = {
            format = "{icon} {volume}% {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = " {volume}%";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [ "" "" "" ];
            };
            on-click = "sleep 0.1 && pavucontrol";
          };
          "custom/exit" = {
            tooltip = false;
            format = "";
            on-click = "sleep 0.1 && wlogout";
          };
          "custom/startmenu" = {
            tooltip = false;
            format = "";
            on-click = "sleep 0.1 && rofi-launcher";
          };
          "custom/hyprbindings" = {
            tooltip = false;
            format = "󱕴";
            on-click = "sleep 0.1 && list-keybinds";
          };
          "idle_inhibitor" = {
            format = "{icon}";
            format-icons = {
              activated = "";
              deactivated = "";
            };
            tooltip = "true";
          };
          "custom/notification" = {
            tooltip = false;
            format = "{icon} {}";
            format-icons = {
              notification = "<span foreground='red'><sup></sup></span>";
              none = "";
              dnd-notification = "<span foreground='red'><sup></sup></span>";
              dnd-none = "";
              inhibited-notification =
                "<span foreground='red'><sup></sup></span>";
              inhibited-none = "";
              dnd-inhibited-notification =
                "<span foreground='red'><sup></sup></span>";
              dnd-inhibited-none = "";
            };
            return-type = "json";
            exec-if = "which swaync-client";
            exec = "swaync-client -swb";
            on-click = "sleep 0.1 && task-waybar";
            escape = true;
          };
          "battery" = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = "󱘖 {capacity}%";
            format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
            on-click = "";
            tooltip = false;
          };
          "custom/arrow1" = { format = ""; };
          "custom/arrow2" = { format = ""; };
          "custom/arrow3" = { format = ""; };
          "custom/arrow4" = { format = ""; };
          "custom/arrow5" = { format = ""; };
          "custom/arrow6" = { format = ""; };
          "custom/arrow7" = { format = ""; };
        }];
        # style = lib.concatStrings [''
        #   * {
        #     font-family: JetBrainsMono Nerd Font Mono;
        #     font-size: 14px;
        #     border-radius: 0px;
        #     border: none;
        #     min-height: 0px;
        #   }
        #   window#waybar {
        #     background: #${config.lib.stylix.colors.base00};
        #     color: #${config.lib.stylix.colors.base05};
        #   }
        #   #workspaces button {
        #     padding: 0px 5px;
        #     background: transparent;
        #     color: #${config.lib.stylix.colors.base04};
        #   }
        #   #workspaces button.active {
        #     color: #${config.lib.stylix.colors.base08};
        #   }
        #   #workspaces button:hover {
        #     color: #${config.lib.stylix.colors.base08};
        #   }
        #   tooltip {
        #     background: #${config.lib.stylix.colors.base00};
        #     border: 1px solid #${config.lib.stylix.colors.base05};
        #     border-radius: 12px;
        #   }
        #   tooltip label {
        #     color: #${config.lib.stylix.colors.base05};
        #   }
        #   #window {
        #     padding: 0px 10px;
        #   }
        #   #pulseaudio, #cpu, #memory, #idle_inhibitor {
        #     padding: 0px 10px;
        #     background: #${config.lib.stylix.colors.base04};
        #     color: #${config.lib.stylix.colors.base00};
        #   }
        #   #custom-startmenu {
        #     color: #${config.lib.stylix.colors.base02};
        #     padding: 0px 14px;
        #     font-size: 20px;
        #     background: #${config.lib.stylix.colors.base0B};
        #   }
        #   #custom-hyprbindings, #network, #battery,
        #   #custom-notification, #custom-exit {
        #     background: #${config.lib.stylix.colors.base0F};
        #     color: #${config.lib.stylix.colors.base00};
        #     padding: 0px 10px;
        #   }
        #   #tray {
        #     background: #${config.lib.stylix.colors.base02};
        #     color: #${config.lib.stylix.colors.base00};
        #     padding: 0px 10px;
        #   }
        #   #clock {
        #     font-weight: bold;
        #     padding: 0px 10px;
        #     color: #${config.lib.stylix.colors.base00};
        #     background: #${config.lib.stylix.colors.base0E};
        #   }
        #   #custom-arrow1 {
        #     font-size: 24px;
        #     color: #${config.lib.stylix.colors.base0E};
        #     background: #${config.lib.stylix.colors.base02};
        #   }
        #   #custom-arrow2 {
        #     font-size: 24px;
        #     color: #${config.lib.stylix.colors.base02};
        #     background: #${config.lib.stylix.colors.base0F};
        #   }
        #   #custom-arrow3 {
        #     font-size: 24px;
        #     color: #${config.lib.stylix.colors.base00};
        #     background: #${config.lib.stylix.colors.base0F};
        #   }
        #   #custom-arrow4 {
        #     font-size: 24px;
        #     color: #${config.lib.stylix.colors.base0F};
        #     background: transparent;
        #   }
        #   #custom-arrow6 {
        #     font-size: 24px;
        #     color: #${config.lib.stylix.colors.base0B};
        #     background: #${config.lib.stylix.colors.base04};
        #   }
        #   #custom-arrow7 {
        #     font-size: 24px;
        #     color: #${config.lib.stylix.colors.base04};
        #     background: transparent;
        #   }
        # ''];
      };

      # programs.waybar = {
      #   enable = true;
      #   settings = [
      #     {
      #       name = "top";
      #       layer = "top"; # Waybar at top layer
      #       position = "top"; # Waybar position (top|bottom|left|right)
      #       height = 32; # Waybar height
      #       spacing = 4;
      #       # Choose the order of the modules
      #       modules-left =
      #         [ "custom/launcher" "sway/workspaces" "sway/window" "sway/mode" ];
      #       modules-center = [ "custom/clock" ];
      #       modules-right = [
      #         "tray"
      #         "pulseaudio"
      #         "battery"
      #         "backlight"
      #         "network"
      #         "custom/notification"
      #         "custom/power"
      #       ];
      #       "sway/workspaces" = {
      #         disable-scroll = true;
      #         disable-markup = false;
      #         all-outputs = true;
      #         format = "  {icon}  ";
      #         #format ="{icon}";
      #         format-icons = {
      #           "1" = "1";
      #           "2" = "2";
      #           "3" = "3";
      #           "4" = "4";
      #           "5" = "5";
      #           "6" = "6";
      #           "7" = "7";
      #           "8" = "8";
      #           "9" = "9";
      #           "10" = "10";
      #           "focused" = "";
      #           "default" = "";
      #         };
      #       };
      #       "custom/launcher" = {
      #         format = " ";
      #         on-click = "nwggrid -b '#060708'";
      #       };
      #       "custom/notification" = {
      #         tooltip = false;
      #         format = " {} {icon}  ";
      #         format-icons = {
      #           notification = "<span foreground='red'><sup></sup></span>";
      #           none = "";
      #           dnd-notification =
      #             "<span foreground='red'><sup></sup></span>";
      #           dnd-none = "";
      #           inhibited-notification =
      #             "<span foreground='red'><sup></sup></span>";
      #           inhibited-none = "";
      #           dnd-inhibited-notification =
      #             "<span foreground='red'><sup></sup></span>";
      #           dnd-inhibited-none = "";
      #         };
      #         return-type = "json";
      #         exec-if = "which swaync-client";
      #         exec = "swaync-client -swb";
      #         on-click = "swaync-client -t -sw";
      #         on-click-right = "swaync-client -d -sw";
      #         escape = true;
      #       };
      #       "custom/power" = {
      #         format = " ⏻  ";
      #         on-click = "nwgbar -b '#060708'";
      #         tooltip = false;
      #       };
      #       "sway/mode" = { format = ''<span style="italic">{}</span>''; };
      #       "sway/language" = {
      #         format = "{}";
      #         max-length = 50;
      #       };
      #       "idle_inhibitor" = {
      #         format = "{icon}";
      #         format-icons = {
      #           activated = "";
      #           deactivated = "";
      #         };
      #       };
      #       "tray" = {
      #         icon-size = 21;
      #         spacing = 10;
      #       };
      #       "custom/clock" = {
      #         exec = "date +'%d. %b %H:%M'";
      #         interval = 10;
      #       };
      #       "backlight" = {
      #         # device = "acpi_video1";
      #         format = " {percent}% {icon}  ";
      #         states = [ "0" "50" ];
      #       };
      #       "pulseaudio" = {
      #         #"scroll-step" = 1;
      #         "format" = "{volume}% {icon}";
      #         "format-bluetooth" = "{volume}% {icon}";
      #         "format-muted" = "";
      #         "format-icons" = {
      #           "headphones" = "";
      #           "handsfree" = "";
      #           "headset" = "";
      #           "phone" = "";
      #           "portable" = "";
      #           "car" = "";
      #           "default" = [ "" "" ];
      #         };
      #         "on-click" = "pavucontrol";
      #       };
      #       "battery" = {
      #         states = {
      #           good = 95;
      #           warning = 30;
      #           critical = 15;
      #         };
      #         format = " {capacity}% {icon}  ";
      #         # "format-good" = ""; # An empty format will hide the module
      #         # "format-full" = "";
      #         format-icons = [ "" "" "" "" "" ];
      #       };
      #       "network" = {
      #         # "interface" = "wlp2s0"; # (Optional) To force the use of this interface
      #         "format-wifi" = "{essid} ({signalStrength}%)  ";
      #         "format-ethernet" = "{ifname} = {ipaddr}/{cidr}  ";
      #         "format-disconnected" = "Disconnected ⚠ ";
      #         "interval" = 7;
      #       };
      #       "bluetooth" = {
      #         format = "<b>{icon}</b>";
      #         format-alt = "{status} {icon}";
      #         interval = 30;
      #         format-icons = {
      #           "enabled" = "";
      #           "disabled" = "";
      #         };
      #         tooltip-format = "{}";
      #       };
      #     }
      #     {
      #       name = "bottom";
      #       layer = "top"; # Waybar at top layer
      #       position = "bottom"; # Waybar position (top|bottom|left|right)
      #       height = 32; # Waybar height
      #       spacing = 20;
      #       # Choose the order of the modules
      #       modules-left = [ "custom/screenshot" "custom/emoji-picker" ];
      #       modules-center = [ "mpris" ];
      #       modules-right = [ "cpu" "memory" "disk" "temperature" ];
      #       # modules-right = [ "custom/gopsuinfo" ];
      #       "cpu" = { format = "{usage}% "; };
      #       "memory" = {
      #         format = "{}% ";
      #         format-alt = " {used:0.1f}G";
      #       };
      #       "disk" = {
      #         format = "{}% ";
      #         tooltip-format = "{used} / {total} used";
      #       };
      #       "temperature" = {
      #         # thermal-zone = 2;
      #         "hwmon-path" = "/sys/class/hwmon/hwmon1/temp1_input";
      #         critical-threshold = 80;
      #         # format-critical = "{temperatureC}°C ";
      #         format = "{temperatureC}°C  ";
      #       };
      #       "custom/gopsuinfo" = {
      #         exec = "gopsuinfo -c gatmnu";
      #         interval = 1;
      #       };
      #       "custom/screenshot" = {
      #         format = "   📸  ";
      #         tooltip-format = "Take a screenshot";
      #         on-click = "sh $HOME/.config/sway/screenshot.sh area";
      #         on-click-middle = "sh $HOME/.config/sway/screenshot.sh window";
      #         on-click-right = "sh $HOME/.config/sway/screenshot.sh output";
      #       };
      #       "custom/emoji-picker" = {
      #         format = "🏳️‍🌈";
      #         tooltip = "true";
      #         tooltip-format = "Pick an emoji and copy it to the clipboard";
      #         on-click = "wofi-emoji";
      #       };
      #     }
      #   ];
      # };

    };
  };
}
