{
  desktop,
  lib,
  username,
  pkgs,
  ...
}:
{
  imports =
    [
      ./programs/emote.nix
      ./programs/aerc.nix
      ./programs/qutebrowser.nix
      (./. + "/${desktop}.nix")
    ]
    ++ lib.optional (builtins.pathExists (
      ./. + "/../users/${username}/desktop.nix"
    )) ../users/${username}/desktop.nix;

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
    "XTerm*faceName" = "FiraCode Nerd Font:size=13:style=Medium:antialias=true";
    "XTerm*boldFont" = "FiraCode Nerd Font:size=13:style=Bold:antialias=true";
    "XTerm*geometry" = "132x50";
    "XTerm.termName" = "xterm-256color";
    "XTerm*locale" = false;
    "XTerm*utf8" = true;
  };
}
