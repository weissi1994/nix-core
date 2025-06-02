{ inputs, ... }: {
  apps.disko-config = {
    tags = [ "disko" ];
    nixos = { host, pkgs, ... }: { };
  };
  defaultTags = { disko = true; };
}
