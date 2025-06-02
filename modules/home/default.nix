{ ... }: {
  imports = [
    ./nixos.nix
    ./console.nix
    ./gopass.nix
    ./packages.nix
    ./desktop
    ./desktop.nix
    ./common.nix
    # ./shell/zsh.nix
    ./shell/fish.nix
    ./nvim.nix # neovim editor
    # ./low-bat-notify.nix
    # from clone
    # ./fastfetch.nix # fetch tool
    # ./git.nix # version control
    # ./hyprland # window manager
    # ./obsidian.nix
    # ./rofi.nix # launcher
    # ./scripts/scripts.nix # personal scripts
    # ./swaylock.nix # lock screen
    # ./swayosd.nix # brightness / volume wiget
    # ./swaync/swaync.nix # notification deamon
    # ./waybar # status bar
    # ./waypaper.nix # GUI wallpaper picker
    # ./xdg-mimes.nix # xdg config
    # ./zsh # shell
  ];
}
