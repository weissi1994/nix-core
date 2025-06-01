{ pkgs, config, ... }:
{
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 14d --keep 10";
    };
    flake = "/home/${config.core.username}/dev/nix";
  };

  environment.systemPackages = with pkgs; [
    nix-output-monitor
    nvd
  ];
}
