{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { nixpkgs, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system: rec {
      nixosConfigurations.test = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs.inputs = inputs;
        modules = [ inputs.core.nixosModules.core ./configuration.nix ];
      };
      apps = {
        default = {
          type = "app";
          program =
            "${nixosConfigurations.test.config.system.build.vm}/bin/run-nixos-vm";
        };
      };
      defaultTags = {
        # when uncommented by default we will not install packages tagged with "development"
        # development = false;
      };

      # Unlike regular Nix, you can bundle nixpkgs/NixOS/home-manager logic together
      apps.emacs = {
        tags = [ "development" ];
        # nixpkgs.params.overlays = [ inputs.emacs-overlay.overlay ];
        nixos = { services.emacs.enable = true; };
        home = { pkgs, ... }:
          {
            # import [ ./services ];
            # 
            # programs.emacs = {
            #   enable = true;
            #   package = pkgs.emacs-unstable;
            # };
          };
      };

      hosts.test-vm = {
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
        tags = {
          # now we tell Nix that our host needs any apps marked as
          # 'development'. This enables simplified host configurations
          # while also empowering users to still fully customize hosts
          # when needed.
          development = true;
          # this is a predifined tag; for apps that are automatically
          # included and optionally enabled, see <modules/apps>
          getting-started = true;
        };
      };
    });
}

{
  description = "My Nix system configuration with nix-config-modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    core = {
      url = "github:weissi1994/nix-core/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
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
        };

        hosts.test-vm = {
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
