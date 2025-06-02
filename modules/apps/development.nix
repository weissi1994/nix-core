# Provides reasonable defaults to get started... mainly
# stuff to ensure your system can reliably rebuild this flake
# in the future.

{ inputs, ... }: {
  apps.development-config = {
    tags = [ "development" ];
    nixos = { host, pkgs, ... }: { };
    home = { };
  };
  defaultTags = { development = true; };
}
