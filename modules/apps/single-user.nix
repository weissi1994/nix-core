# I don't want to force anybody to use single-user configs, so it's
# possible to enable or disable this with tags. In the future I may
# specify a separate module for multi-user configurations.

{ lib, ... }:
let inherit (lib) mkOption types;
in {
  options = {
    hosts = mkOption {
      type = types.attrsOf (types.submodule ({ config, ... }: {
        options = {
          username = mkOption {
            type = types.str;
            default = "user";
            description = ''
              The username of the single user for this system.
            '';
          };
          email = mkOption {
            type = types.str;
            default = "";
            description = ''
              The email for the single user.
            '';
          };
          homeDirectory = mkOption {
            type = types.path;
            default = "/home/${config.username}";
            description = lib.mdDoc ''
              The path to the home directory for this user. Defaults to
              `/home/<username>`
            '';
          };
          sshKeys = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "authorized ssh keys";
          };
        };
      }));
    };
  };

  config = {
    apps.single-user-config = {
      tags = [ "single-user" ];
      nixos = { host, config, pkgs, ... }:
        let
          ifExists = groups:
            builtins.filter (group: builtins.hasAttr group config.users.groups)
            groups;
        in {
          nix.settings = { trusted-users = [ host.username ]; };
          users = {
            users.${host.username} = {
              isNormalUser = true;
              home = host.homeDirectory;
              group = host.username;
              shell = pkgs.fish;
              description = host.username;
              extraGroups = [ "wheel" ] ++ ifExists [
                "networkmanager"
                "docker"
                "podman"
                "audio"
                "video"
                "users"
                "input"
              ];
              openssh.authorizedKeys.keys = host.sshKeys;
            };
            users.root = {
              hashedPassword = null;
              openssh.authorizedKeys.keys = host.sshKeys;
            };
            groups.${host.username} = { };
          };
          programs.fish.enable = true;
        };

      darwin = { host, ... }: {
        nixpkgs.pkgs = host._internal.pkgs;
        nix.settings = {
          trusted-users = [ host.username ];
          experimental-features = [ "nix-command" "flakes" ];
        };
        users.users.${host.username} = { home = host.homeDirectory; };
      };

      home = { host, ... }: {
        home = { inherit (host) username homeDirectory; };
      };
    };
    defaultTags = { single-user = lib.mkDefault true; };
  };
}
