{
  pkgs,
  config,
  lib,
  ...
}:
{
  networking = {
    hostName = "${config.core.hostname}";
    useDHCP = lib.mkDefault true;
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openconnect
        networkmanager-openvpn
        networkmanager-vpnc
      ];
      wifi = {
        powersave = false;
      };
    };
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
      ];
    };
  };
  programs.nm-applet.enable = true;

  services.resolved = {
    enable = true;
    dnssec = "false";
    domains = [ "~." ];
    fallbackDns = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    dnsovertls = "opportunistic";
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    ifwifi
  ];
}
