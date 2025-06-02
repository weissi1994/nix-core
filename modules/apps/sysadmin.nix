# Provides reasonable defaults to get started... mainly
# stuff to ensure your system can reliably rebuild this flake
# in the future.

{ inputs, ... }: {
  apps.sysadmin-config = {
    tags = [ "sysadmin" ];
    nixos = { host, pkgs, ... }: { };
    home = { };
  };
  defaultTags = { sysadmin = true; };
}
