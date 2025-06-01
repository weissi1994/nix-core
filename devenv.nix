{ pkgs, ... }:

{
  packages = [ pkgs.git ];

  scripts.update-flake.exec = ''
    nix flake update --refresh --commit-lock-file
  '';

  scripts.topology.exec = ''
    nix build .#topology.x86_64-linux.config.output
  '';

  languages.nix.enable = true;
  languages.shell.enable = true;

  git-hooks.hooks = {
    ripsecrets.enable = true;
    check-added-large-files.enable = true;
    check-case-conflicts.enable = true;
    check-executables-have-shebangs.enable = true;
    check-merge-conflicts.enable = true;
    check-shebang-scripts-are-executable.enable = true;
    check-symlinks.enable = true;
    detect-private-keys.enable = true;
    end-of-file-fixer.enable = true;
    fix-byte-order-marker.enable = true;
    forbid-new-submodules.enable = true;
    mixed-line-endings.enable = true;
    trim-trailing-whitespace.enable = true;
    # Formatters
    nixfmt-rfc-style.enable = true;
    deadnix.enable = true;
    shellcheck.enable = true;
  };

  # See full reference at https://devenv.sh/reference/options/
}
