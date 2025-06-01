{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    asn
    termshark
    dog
    nmap
    trippy
    gping
    ipcalc
    certigo
    dhcpdump
  ];
}
