{ inputs, ... }:
{
  imports = [
    # Disko
    ./disks.nix
    inputs.disko.nixosModules.disko
  ];
}
