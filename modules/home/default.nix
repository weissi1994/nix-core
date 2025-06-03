{ ... }: {
  imports = [
    ./desktop
    # ./shell/zsh.nix
    ./shell/fish.nix
    # ./low-bat-notify.nix
    # from clone
    # ./fastfetch.nix # fetch tool
    # ./hyprland # window manager
    # ./rofi.nix # launcher
    # ./scripts/scripts.nix # personal scripts
    # ./swaylock.nix # lock screen
    # ./swayosd.nix # brightness / volume wiget
    # ./swaync/swaync.nix # notification deamon
    # ./waybar # status bar
    # ./zsh # shell
  ];
}
