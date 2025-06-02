# Provides reasonable defaults to get started... mainly
# stuff to ensure your system can reliably rebuild this flake
# in the future.

{ inputs, ... }: {
  apps.nvidia-config = {
    tags = [ "nvidia" ];
    nixos = { host, pkgs, ... }: { };
    home = { };
  };
  defaultTags = { nvidia = false; };
}
