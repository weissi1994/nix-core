{ inputs, lib, ... }:
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
in {
  apps.waybar-config = {
    tags = [ "desktop" ];
    # enablePredicate = { host, ... }:
    #   host.desktop == "waybar" || host.desktop == "hyprland";

    nixos = { host, pkgs, ... }: { };

    home = { host, pkgs, config, ... }: {
      home = {
        file = { ".config/screenshot.sh".source = ../files/screenshot.sh; };
      };
      programs.waybar = with colors; {
        enable = true;
        package = pkgs.waybar;
        settings = [{
          layer = "top";
          position = "top";

          modules-center = [
            "network"
            "pulseaudio"
            "cpu"
            "hyprland/workspaces"
            "memory"
            "disk"
            "clock"
          ]; # Eterna: [ "hyprland/window" ]
          modules-left = [
            "custom/startmenu"
            "hyprland/window"
          ]; # Eternal:  [ "hyprland/workspaces" "cpu" "memory" "network" ]
          modules-right = [
            "tray"
            "backlight"
            "custom/screenshot"
            "custom/notification"
            "battery"
            "custom/exit"
          ]; # Eternal: [ "idle_inhibitor" "pulseaudio" "clock"  "custom/notification" "tray" ]

          "hyprland/workspaces" = {
            format = "{name}";
            format-icons = {
              default = " ";
              active = " ";
              urgent = " ";
            };
            all-outputs = true;
            on-scroll-up = "hyprctl dispatch workspace e+1";
            on-scroll-down = "hyprctl dispatch workspace e-1";
          };
          "backlight" = {
            # device = "acpi_video1";
            format = "{icon} {percent}%";
            states = [ "0" "50" ];
            on-scroll-up = "brightnessctl set +10%";
            on-scroll-down = "brightnessctl set -10%";
          };
          "clock" = {
            format = " {:%H:%M}";
            # ''{: %I:%M %p}'';
            tooltip = true;
            tooltip-format =
              "<big>{:%A, %d.%B %Y }</big></br><tt><small>{calendar}</small></tt>";
          };
          "hyprland/window" = {
            max-length = 60;
            separate-outputs = false;
          };
          "memory" = {
            interval = 5;
            format = " {}%";
            tooltip = true;
            on-click = "${terminal} -e btm";
          };
          "cpu" = {
            interval = 5;
            format = " {usage:2}%";
            tooltip = true;
            on-click = "${terminal} -e btm";
          };
          "disk" = {
            format = " {free}";
            tooltip = true;
            # Not working with zaneyos window open then closes
            on-click = "${terminal} -e gdu";
          };
          "network" = {
            format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
            format-ethernet = " {bandwidthDownBits}";
            format-wifi = " {bandwidthDownBits}";
            format-disconnected = "󰤮";
            tooltip = false;
            on-click = "${terminal} -e btm";
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
            on-click = "pavucontrol";
          };
          "custom/exit" = {
            tooltip = false;
            format = "⏻";
            on-click = "sleep 0.1 && wlogout";
          };
          "custom/startmenu" = {
            tooltip = false;
            format = " ";
            on-click = "albert show";
          };
          "idle_inhibitor" = {
            format = "{icon}";
            format-icons = {
              activated = " ";
              deactivated = " ";
            };
            tooltip = "true";
          };
          "custom/screenshot" = {
            format = "📸 ";
            tooltip-format = "Take a screenshot";
            on-click = "sh $HOME/.config/screenshot.sh area";
            on-click-middle = "sh $HOME/.config/screenshot.sh window";
            on-click-right = "sh $HOME/.config/screenshot.sh output";
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
            on-click = "swaync-client -t";
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
        }];
        style = lib.concatStrings [''
          * {
            font-size: 16px;
            font-family: JetBrainsMono Nerd Font, Font Awesome, sans-serif;
            font-weight: bold;
          }
          window#waybar {
            /*

              background-color: rgba(26,27,38,0);
              border-bottom: 1px solid rgba(26,27,38,0);
              border-radius: 0px;
              color: ${base0F};
            */

            background-color: rgba(26,27,38,0);
            border-bottom: 1px solid rgba(26,27,38,0);
            border-radius: 0px;
            color: ${base0F};
          }
          #workspaces {
            /*
              Eternal
              background: linear-gradient(180deg, ${base00}, ${base01});
              margin: 5px 5px 5px 0px;
              padding: 0px 10px;
              border-radius: 0px 15px 50px 0px;
              border: 0px;
              font-style: normal;
              color: ${base00};
            */
            background: linear-gradient(45deg, ${base01}, ${base01});
            margin: 5px;
            padding: 0px 1px;
            border-radius: 15px;
            border: 0px;
            font-style: normal;
            color: ${base00};
          }
          #workspaces button {
            padding: 0px 5px;
            margin: 4px 3px;
            border-radius: 15px;
            border: 0px;
            color: ${base00};
            background: linear-gradient(45deg, ${base0D}, ${base0E});
            opacity: 0.5;
            transition: all 0.3s ease-in-out;
          }
          #workspaces button.active {
            padding: 0px 5px;
            margin: 4px 3px;
            border-radius: 15px;
            border: 0px;
            color: ${base00};
            background: linear-gradient(45deg, ${base0D}, ${base0E});
            opacity: 1.0;
            min-width: 40px;
            transition: all 0.3s ease-in-out;
          }
          #workspaces button:hover {
            border-radius: 15px;
            color: ${base00};
            background: linear-gradient(45deg, ${base0D}, ${base0E});
            opacity: 0.8;
          }
          tooltip {
            background: ${base00};
            border: 1px solid ${base0E};
            border-radius: 10px;
          }
          tooltip label {
            color: ${base07};
          }
          #window {
            /*
              Eternal
              color: ${base05};
              background: ${base00};
              border-radius: 15px;
              margin: 5px;
              padding: 2px 20px;
            */
            margin: 5px;
            padding: 2px 20px;
            color: ${base05};
            background: ${base01};
            border-radius: 50px 15px 50px 15px;
          }
          #memory {
            color: ${base0F};
            /*
              Eternal
              background: ${base00};
              border-radius: 50px 15px 50px 15px;
              margin: 5px;
              padding: 2px 20px;
            */
            background: ${base01};
            margin: 5px;
            padding: 2px 20px;
            border-radius: 15px 50px 15px 50px;
          }
          #clock {
            color: ${base0B};
              background: ${base00};
              border-radius: 15px 50px 15px 50px;
              margin: 5px;
              padding: 2px 20px;
          }
          #idle_inhibitor {
            color: ${base0A};
              background: ${base00};
              border-radius: 50px 15px 50px 15px;
              margin: 5px;
              padding: 2px 20px;
          }
          #cpu {
            color: ${base07};
              background: ${base00};
              border-radius: 50px 15px 50px 15px;
              margin: 5px;
              padding: 2px 20px;
          }
          #disk {
            color: ${base0F};
              background: ${base00};
              border-radius: 15px 50px 15px 50px;
              margin: 5px;
              padding: 2px 20px;
          }
          #battery {
            color: ${base08};
            background: ${base00};
            border-radius: 15px 50px 15px 50px;
            margin: 5px;
            padding: 2px 20px;
          }
          #network {
            color: ${base09};
            background: ${base00};
            border-radius: 50px 15px 50px 15px;
            margin: 5px;
            padding: 2px 20px;
          }
          #tray {
            color: ${base05};
            background: ${base00};
            border-radius: 15px 50px 15px 50px;
            margin: 5px;
            padding: 2px 20px;
          }
          #pulseaudio {
            color: ${base0D};
            /*
              Eternal
              background: ${base00};
              border-radius: 15px 50px 15px 50px;
              margin: 5px;
              padding: 2px 20px;
            */
            background: ${base01};
            margin: 4px;
            padding: 2px 20px;
            border-radius: 50px 15px 50px 15px;
          }
          #custom-screenshot {
            color: ${base0A};
            background: ${base00};
            border-radius: 15px 50px 15px 50px;
            margin: 5px;
            padding: 2px 20px;
          }
          #custom-notification {
            color: ${base0C};
            background: ${base00};
            border-radius: 15px 50px 15px 50px;
            margin: 5px;
            padding: 2px 20px;
          }
          #custom-startmenu {
            color: ${base0E};
            background: ${base00};
            border-radius: 0px 15px 50px 0px;
            margin: 5px 5px 5px 0px;
            padding: 2px 20px;
          }
          #backlight {
            color: ${base0A};
            background: ${base00};
            border-radius: 15px 50px 15px 50px;
            margin: 5px;
            padding: 2px 20px;
          }
          #idle_inhibitor {
            color: ${base09};
            background: ${base00};
            border-radius: 15px 50px 15px 50px;
            margin: 5px;
            padding: 2px 20px;
          }
          #custom-exit {
            color: ${base0E};
            background: ${base00};
            border-radius: 15px 0px 0px 50px;
            margin: 5px 0px 5px 5px;
            padding: 2px 20px;
          }
        ''];
      };
      home.packages = with pkgs; [
        brightnessctl
        grim
        slurp
        sway-contrib.grimshot
        swappy
        swaynotificationcenter
        swaynag-battery
      ];
    };
  };
}
