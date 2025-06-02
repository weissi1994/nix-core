{ inputs, ... }: {
  apps.server-config = {
    tags = [ "server" ];
    nixos = { host, pkgs, ... }: { };
    home = { };
  };
  defaultTags = { server = false; };
}
