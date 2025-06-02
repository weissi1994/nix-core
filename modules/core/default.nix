{ lib, inputs, ... }: {
  imports = [
    # 3rd party modules
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    inputs.nixvim.nixosModules.nixvim
    inputs.hyprland.nixosModules.default
    # Custom modules
    ./disko
    ./opensnitch.nix
    ./xserver.nix
    ./desktop
    ./services.nix
    ./user.nix
    ./virtualization.nix
    ./home-manager.nix # TODO: migrate hm stuff
  ];

  options.core = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "system username";
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "installer";
      description = "system hostname";
    };
    desktop = lib.mkOption {
      type = lib.types.str;
      default = "sway";
      description = "Set to null to disable";
    };
    installer = lib.mkEnableOption "Enable installer module";
    offline_installer = lib.mkEnableOption "Enable offline-installer";
  };
  # options = {
  #   core = mkOption {
  #     type = types.attrsOf (types.submodule ({ config, ... }: {
  #       options = {
  #         username = mkOption {
  #           type = types.str;
  #           default = "user";
  #           description = ''
  #             The username of the single user for this system.
  #           '';
  #         };
  #         email = mkOption {
  #           type = types.str;
  #           default = "";
  #           description = ''
  #             The email for the single user.
  #           '';
  #         };
  #         homeDirectory = mkOption {
  #           type = types.path;
  #           default = "/home/${config.username}";
  #           description = lib.mdDoc ''
  #             The path to the home directory for this user. Defaults to
  #             `/home/<username>`
  #           '';
  #         };
  #       };
  #     }));
  #   };
  # };

  # config = {
  #   apps.single-user-config = {
  #     tags = [ "single-user" ];
  #     nixos = { host, ... }: {
  #       nix.settings = { trusted-users = [ host.username ]; };
  #       users.users.${host.username} = {
  #         isNormalUser = true;
  #         home = host.homeDirectory;
  #         group = host.username;
  #         description = host.username;
  #       };
  #       users.groups.${host.username} = { };
  #     };

  #     darwin = { host, ... }: {
  #       nixpkgs.pkgs = host._internal.pkgs;
  #       nix.settings = {
  #         trusted-users = [ host.username ];
  #         experimental-features = [ "nix-command" "flakes" ];
  #       };
  #       users.users.${host.username} = { home = host.homeDirectory; };
  #     };

  #     home = { host, ... }: {
  #       home = { inherit (host) username homeDirectory; };
  #     };
  #   };
  #   defaultTags = { single-user = true; };
  # };

  # core = {
  #   steam.enable = lib.mkDefault true;
  #   virtualization.enable = lib.mkDefault false;
  #   installer = lib.mkDefault false;
  #   offline_installer = lib.mkDefault false;
  # };
}
