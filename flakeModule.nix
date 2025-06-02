{ config, lib, inputs, flake-parts-lib, ... }:
let
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkSubmoduleOptions;
in {
  options = {
    # compatibility layer for home-manager
    flake.homeConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
    };

    core = mkOption {
      type = types.submoduleWith {
        modules = (import ./modules/all-modules.nix)
          ++ [{ _module.args.inputs = inputs; }];
      };
    };
  };

  config = {
    flake = {
      darwinConfigurations = config.core.darwinConfigurations;
      homeConfigurations = config.core.homeConfigurations;
      nixosConfigurations = config.core.nixosConfigurations;
    };
  };
}
