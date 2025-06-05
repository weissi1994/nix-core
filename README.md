# nix-core

Based on [github:chadac/nix-config-modules](https://github.com/chadac/nix-config-modules).

## Getting started

This uses [flake-parts](https://flake.parts). You don't have to (and I
built it without any explicit dependencies on it) but I leave it as an
exercise to the reader to figure out how to use this otherwise.

See [./example/](./example/) for an example usage.

This will create a basic Flake with some predefined defaults for a
single-user NixOS system with home-manager enabled. You may then
build/switch to the system using:

    nixos-rebuild switch --flake .#my-host

Or with home-manager:

    home-manager switch --flake .#my-host

Since this is layered with `flake-parts` you may then choose to
manage/deploy your hosts however you wish.

For a more in-depth example of how this can be used, see
[github:chadac/dotfiles](https://github.com/chadac/dotfiles).
