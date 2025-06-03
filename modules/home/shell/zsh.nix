{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cava # for cli equealizer #unixporn
    jless # json less
    sd # modern sed
    choose # modern cut
    gnumake
    yank # Yank terminal output to clipboard.
    # zsh plugins
    tmux
    thefuck
    meslo-lgs-nf
    grc
    fzf
  ];

  programs = {
    nix-index = {
      enable = true;
      enableBashIntegration = false;
      enableZshIntegration = false;
      enableFishIntegration = false;
    };
    command-not-found.enable = true;

  };
}
