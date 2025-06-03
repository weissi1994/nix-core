{
  description = "NixOS Core Flake Modules";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://cache.nixos.org" ];
    trusted-public-keys =
      [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nova.url = "git+https://gitlab.n0de.biz/daniel/nvim-config?ref=main";
    nova.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { ... }@inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      flake.flakeModule = import ./flakeModule.nix;

      systems = import inputs.systems;
      perSystem = { pkgs, lib, ... }:
        let
          eval =
            lib.evalModules { modules = import ./modules/all-modules.nix; };
        in {
          packages.docs =
            (pkgs.nixosOptionsDoc { options = eval.options; }).optionsAsciiDoc;
        };
    };
}
