{ pkgs, ... }:
{
  home.packages = with pkgs; [
    unstable.brave
    unstable.google-chrome
  ];
}
