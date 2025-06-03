{ inputs, lib, ... }: {
  apps.server-config = {
    tags = [ "server" ];
    nixos = { host, pkgs, ... }: { };
    home = { };
  };
  defaultTags = { server = lib.mkDefault false; };
}
