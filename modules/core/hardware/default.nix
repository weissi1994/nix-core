{ pkgs, config, ... }:
{
  hardware = {
    graphics = {
      enable = true;
    };
  };
  hardware.enableRedistributableFirmware = true;

  powerManagement.enable = true;
  powerManagement.powertop.enable = true;

  environment.systemPackages =
    with pkgs;
    [
      nvme-cli
      smartmontools
    ]
    ++ lib.optionals (config.core.desktop != null) [ gsmartcontrol ];

  services.smartd.enable = true;

  services = {
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
      '';
    };
  };

  systemd.sleep.extraConfig = "HibernateDelaySec=5m";
}
