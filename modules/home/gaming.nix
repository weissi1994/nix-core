{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ## Utils
    # gamemode
    # gamescope
    # winetricks

    ## Minecraft
    # prismlauncher

    ## Cli games
    vitetris
    # nethack

    ## Celeste
    # celeste-classic
    # celeste-classic-pm

    ## Doom
    # gzdoom
    # crispy-doom

    ## Emulation
    # sameboy
    # snes9x
    # cemu
    # dolphin-emu
  ];
}
