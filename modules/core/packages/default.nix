{ pkgs, ... }:
{
  imports = [
    ./ctf.nix
    ./sysadmin.nix
  ];

  environment.systemPackages = with pkgs; [
    inxi
    dmidecode
    htop
    gping
    httpie
    xh
  ];
}
