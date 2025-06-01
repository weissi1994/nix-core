{
  pkgs,
  lib,
  inputs,
  config,
  username,
  ...
}:
{

  home = {
    activation.report-changes = config.lib.dag.entryAnywhere ''
      ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
    '';
    homeDirectory = "/home/${username}";
    sessionPath = [ "$HOME/.local/bin" ];
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    package = lib.mkForce pkgs.unstable.nix;
    settings = {
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Avoid unwanted garbage collection when using nix-direnv
      keep-outputs = true;
      keep-derivations = true;
      warn-dirty = false;
    };
  };
}
