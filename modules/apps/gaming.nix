{ inputs, ... }: {
  apps.gaming-config = {
    tags = [ "gaming" ];
    nixos = { host, pkgs, ... }: { };
    home = { };
  };
  defaultTags = { gaming = false; };
}
