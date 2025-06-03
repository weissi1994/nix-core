{ inputs, lib, ... }: {
  apps.development-config = {
    tags = [ "development" ];
    nixos = { host, pkgs, ... }: { };
    home = { };
  };
  defaultTags = { development = lib.mkDefault true; };
}
