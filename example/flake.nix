{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    core = {
      url = "github:weissi1994/nix-core";
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
    });
}
