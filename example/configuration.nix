{ config, lib, pkgs, ... }: {
  # customize kernel version
  boot.kernelPackages = pkgs.linuxPackages_5_15;

  core = {
    hostname = "test-vm";
    username = "admin";
    desktop = "sway";
    os_disk = "/dev/vda";
    ssh_keys = [ ];
  };

  defaultTags = {
    # by default we will not install packages tagged with "development"
    development = false;
  };

  # Unlike regular Nix, you can bundle nixpkgs/NixOS/home-manager logic together
  apps.emacs = {
    tags = [ "development" ];
    # nixpkgs.params.overlays = [ inputs.emacs-overlay.overlay ];
    nixos = { services.emacs.enable = true; };
    home = { pkgs, ... }:
      {
        # import [ ./services ];
        # 
        # programs.emacs = {
        #   enable = true;
        #   package = pkgs.emacs-unstable;
        # };
      };
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
      # this is a predifined tag; for apps that are automatically
      # included and optionally enabled, see <modules/apps>
      getting-started = true;
    };
  };

  users.groups.admin = { };
  users.users = {
    admin = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      password = "admin";
      group = "admin";
    };
  };

  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      memorySize = 2048; # Use 2048MiB memory.
      cores = 3;
      graphics = false;
    };
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  networking.firewall.allowedTCPPorts = [ 22 ];
  environment.systemPackages = with pkgs; [ htop ];

  system.stateVersion = "25.05";
}
