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

    stylix = {
      url = "github:danth/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    hypr-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
    };

    hyprpicker = {
      url = "github:hyprwm/hyprpicker";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
    };

    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs = {
        hyprgraphics.follows = "hyprland/hyprgraphics";
        hyprlang.follows = "hyprland/hyprlang";
        hyprutils.follows = "hyprland/hyprutils";
        nixpkgs.follows = "hyprland/nixpkgs";
        systems.follows = "hyprland/systems";
      };
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nova.url = "git+https://gitlab.n0de.biz/daniel/nvim-config?ref=main";
    nova.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, ... }@inputs:
    let
      testVM = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.inputs = inputs;
        modules =
          [ self.nixosConfigurations.test-vm ./example/configuration.nix ];
      };
    in inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      # import core-modules
      imports = [ inputs.core.flakeModule ];

      # this avoids errors when running `nix flake show`
      systems = [ "x86_64-linux" ];
      perSystem = { pkgs, lib, ... }:
        let
          eval =
            lib.evalModules { modules = import ./modules/all-modules.nix; };
        in {
          packages.docs =
            (pkgs.nixosOptionsDoc { options = eval.options; }).optionsAsciiDoc;

          # ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no admin@localhost -p 2221
          apps = {
            default = {
              type = "app";
              program = "${testVM.config.system.build.vm}/bin/run-nixos-vm";
            };
          };
        };

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
