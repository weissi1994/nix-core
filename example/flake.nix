{
  description = "My Nix system configuration with nix-config-modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    core = {
      url = "path:./../";
      # url = "github:weissi1994/nix-core";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nova = {
      url = "github:weissi1994/nvim-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      # import core-modules
      imports = [ inputs.core.flakeModule ];

      # this avoids errors when running `nix flake show`
      systems = [ ];

      nix-config = {
        # Tags are described below in more detail: You can use these as an
        # alternative to enabling/disabling applications.
        defaultTags = {
          # by default we will not install packages tagged with "development"
          development = false;
          desktop = false;
        };

        # To import existing configurations globally:
        # modules = {
        #   nixos = [ ./configuration.nix ];
        #   home-manager = [ ./home.nix ];
        # };

        # nix build .#nixosConfigurations.test.vm
        # ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no admin@localhost -p 2221
        hosts.test = {
          # host types can be "nixos" and "home-manager"
          # "nixos" is for systems that build NixOS; home-manager is bundled with it
          # "home-manager" is for systems that install just HM (for example, darwin etc)
          kind = "nixos";
          # defines the system that your host runs on
          system = "x86_64-linux";
          # on single user systems you can specify your username straight up.
          # multi-user support is "upcoming"
          username = "admin";
          # optional metadata... useful for stuff like Git
          email = "admin@example.com";
          # you can customize your home directory, otherwise defaults to
          # `/home/<username>`
          homeDirectory = "/home/admin";
          desktop = null;

          # each host can specify custom nixos/home/nixpkgs attributes to customize
          # their own configuration
          nixos = {
            imports = [
              # ./hardware-configuration.nix
              ./configuration.nix
            ];
          };
          home = { imports = [ ]; };

          tags = {
            # now we tell Nix that our host needs any apps marked as
            # 'development'. This enables simplified host configurations
            # while also empowering users to still fully customize hosts
            # when needed.
            development = true;
          };
        };
      };
    };
}
