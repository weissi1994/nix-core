{ ... }:
{
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
    # ./bat.nix # better cat command
    # ./browser.nix # firefox based browser
    # ./btop.nix # resouces monitor
    # ./cava.nix # audio visualizer
    # ./discord.nix # discord
    # ./fastfetch.nix # fetch tool
    # ./fzf.nix # fuzzy finder
    # ./gaming.nix # packages related to gaming
    # ./git.nix # version control
    # ./gtk.nix # gtk theme
    # ./kitty.nix # terminal
    # ./lazygit.nix
    # ./hyprland # window manager
    # ./nemo.nix # file manager
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
