{ pkgs, ... }:
let
  battery-monitor = pkgs.writeShellScriptBin "battery-monitor" ''
    battery_level=$(${pkgs.acpi}/bin/acpi -b | ${pkgs.busybox}/bin/sed -n 's/.*\ \([[:digit:]]\{1,3\}\)\%.*/\1/;p')
    battery_state=$(${pkgs.acpi}/bin/acpi -b | ${pkgs.busybox}/bin/awk '{print $3}' | ${pkgs.coreutils-full}/bin/tr -d ",")
    battery_remaining=$(${pkgs.acpi}/bin/acpi -b | ${pkgs.busybox}/bin/sed -n '/Discharging/{s/^.*\ \([[:digit:]]\{2\}\)\:\([[:digit:]]\{2\}\).*/\1h \2min/;p}')
    backlight_cmd="${pkgs.brightnessctl}/bin/brightnessctl"
    _battery_threshold_level="25"
    _battery_critical_level="15"
    _battery_critical2_level="10"
    _battery_suspend_level="5"

    if [ ! -f "/tmp/.battery" ]; then
        ${pkgs.busybox}/bin/echo "''${battery_level}" > /tmp/.battery
        ${pkgs.busybox}/bin/echo "''${battery_state}" >> /tmp/.battery
        exit
    fi

    previous_battery_level=$(${pkgs.busybox}/bin/cat /tmp/.battery | ${pkgs.busybox}/bin/head -n 1)
    previous_battery_state=$(${pkgs.busybox}/bin/cat /tmp/.battery | ${pkgs.busybox}/bin/tail -n 1)
    ${pkgs.busybox}/bin/echo "''${battery_level}" > /tmp/.battery
    ${pkgs.busybox}/bin/echo "''${battery_state}" >> /tmp/.battery

    checkBatteryLevel() {
        if [ "''${battery_state}" != "Discharging" ] || [ "''${battery_level}" == "''${previous_battery_level}" ]; then
            exit
        fi

        if [ ''${battery_level} -le ''${_battery_suspend_level} ]; then
            systemctl suspend-then-hibernate
        elif [ ''${battery_level} -le ''${_battery_critical2_level} ]; then
            ${pkgs.libnotify}/bin/notify-send "Low Battery" "Your computer will suspend soon unless plugged into a power outlet." -u critical
        elif [ ''${battery_level} -le ''${_battery_critical_level} ]; then
            ${pkgs.libnotify}/bin/notify-send "Low Battery" "Your computer will suspend soon unless plugged into a power outlet. (''${battery_remaining}) of battery remaining." -u critical
      ''${backlight_cmd} set 50%
        elif [ ''${battery_level} -le ''${_battery_threshold_level} ]; then
            ${pkgs.libnotify}/bin/notify-send "Low Battery" "''${battery_level}% (''${battery_remaining}) of battery remaining." -u normal
      ''${backlight_cmd} set 75%
        fi
    }

    checkBatteryStateChange() {
        if [ "''${battery_state}" != "Discharging" ] && [ "''${previous_battery_state}" == "Discharging" ]; then
            ${pkgs.libnotify}/bin/notify-send "Charging" "Battery is now plugged in." -u low
      ''${backlight_cmd} set 100%

        fi

        if [ "''${battery_state}" == "Discharging" ] && [ "''${previous_battery_state}" != "Discharging" ]; then
            ${pkgs.libnotify}/bin/notify-send "Power Unplugged" "Your computer has been disconnected from power." -u low
        fi
    }

    checkBatteryStateChange
    checkBatteryLevel
  '';
in
{
  systemd.user.services.battery-monitor = {
    Unit = {
      Description = "Battery Monitor";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "notify";
      ExecStart = "${battery-monitor}/bin/battery-monitor";
      Restart = "always";
      RestartSec = 60;
    };
  };
}
