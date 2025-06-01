# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{ pkgs ? (import ../nixpkgs.nix) { } }: {
  # example = pkgs.callPackage ./example { };
  # default = nixvim.legacyPackages.${system};
  # nvim = nixvim.makeNixvimWithModule {
  #   module = ./home/_mixins/programs/nvim;
  # };
}
