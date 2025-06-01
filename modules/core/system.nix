{
  pkgs,
  lib,
  inputs,
  outputs,
  config,
  ...
}:
{
  # imports = [ inputs.nix-gaming.nixosModules.default ];
  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    optimise.automatic = true;
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];

      # Avoid unwanted garbage collection when using nix-direnv
      keep-outputs = true;
      keep-derivations = true;

      warn-dirty = false;
      trusted-users = [ "@wheel" ];
    };
  };

  services.envfs.enable = true;
  services.udev.packages = [ pkgs.android-udev-rules ];

  environment = {
    # Eject nano and perl from the system
    defaultPackages =
      with pkgs;
      lib.mkForce [
        gitMinimal
        home-manager
        deploy-rs
        vim
        rsync
      ];
    systemPackages = with pkgs; [
      file
      wget
      curl
      git
      devenv
      unstable.aichat
      pinentry-curses
      imagemagickBig
      pinentry-gnome3
      gettext
      age
      bc
      zip
      cachix
      comma
      unstable.nh
      sops
      pciutils
      lapce
      psmisc
      unzip
      usbutils
      ethtool
      wget
      dnsutils
      nix-diff
      comma
      deadnix
      strongswan
      openssl
      puppet-lint
      inputs.nova.packages.${system}.default
    ];
    variables = {
      EDITOR = "nvim";
      SYSTEMD_EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };
  time.timeZone = "ETC/UTC";
  environment = {
    shellAliases = {
      l = "ls -lah";
      la = "ls -a";
      ll = "ls -l";
      lla = "ls -la";
      tree = "ls --tree";
    };
  };

  # Only install the docs I use
  documentation = {
    enable = lib.mkDefault true;
    nixos.enable = lib.mkDefault false;
    man.enable = true;
    info.enable = lib.mkDefault false;
    doc.enable = lib.mkDefault false;
  };

  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      # outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Accept the joypixels license
      joypixels.acceptLicense = true;
    };
  };

  programs = {
    nix-ld.enable = true;
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions = {
        enable = true;
        strategy = [
          "completion"
          "match_prev_cmd"
        ];
      };
      syntaxHighlighting.enable = true;
    };
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    enableExtraSocket = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  services.fwupd.enable = true;

  systemd.tmpfiles.rules = [
    "d /nix/var/nix/profiles/per-user/${config.core.username} 0755 ${config.core.username} root"
    "d /mnt/${config.core.username} 0755 ${config.core.username} users"
  ];
  system.stateVersion = config.core.stateVersion;
}
