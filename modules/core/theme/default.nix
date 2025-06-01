{ lib, pkgs, ... }:
{
  stylix = {
    enable = true;
    image = ./background.png;

    polarity = "dark";

    base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
    targets.plymouth.logo = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/f84c13adae08e860a7c3f76ab3a9bef916d276cc/logo/nix-snowflake-colours.svg";
      sha256 = "pHYa+d5f6MAaY8xWd3lDjhagS+nvwDL3w7zSsQyqH7A=";
    };

    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        package = pkgs.fira-code;
        name = "Fira Code";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}
