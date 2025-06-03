{ pkgs, ... }:
{
  home.packages = with pkgs; [
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
