{ lib, inputs, ... }: {
  imports = [
    # 3rd party modules
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    inputs.nixvim.nixosModules.nixvim
    inputs.hyprland.nixosModules.default
    # Custom modules
    ./bootloader.nix
    ./hardware
    ./disko
    ./network.nix
    ./console.nix
    ./openssh.nix
    ./fonts.nix
    ./opensnitch.nix
    ./xserver.nix
    ./nh.nix
    ./pipewire.nix
    ./security.nix
    ./packages
    ./desktop
    ./services.nix
    ./steam.nix
    ./theme
    ./system.nix
    ./user.nix
    ./container.nix
    ./virtualization.nix
    ./home-manager.nix # TODO: migrate hm stuff
  ];

  options.core = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "system username";
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "installer";
      description = "system hostname";
    };
    desktop = lib.mkOption {
      type = lib.types.str;
      default = "sway";
      description = "Set to null to disable";
    };
    os_disk = lib.mkOption {
      type = lib.types.str;
      default = "/dev/sda";
      description = "system root disk";
    };
    os_layout = lib.mkOption {
      type = lib.types.str;
      default = "btrfs";
      description = "supported are: btrfs, bcachefs";
    };
    platform = lib.mkOption {
      type = lib.types.str;
      default = "x86_64-linux";
      description = "system architecture";
    };
    stateVersion = lib.mkOption {
      type = lib.types.str;
      default = "25.05";
      description = "nixos state version";
    };
    ssh_keys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "system user ssh keys";
    };
    data_disks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "raid disks (exactly 2 expected)";
    };
    data_layout = lib.mkOption {
      type = lib.types.str;
      default = "mdraid";
      description = "supported are: mdraid";
    };
    installer = lib.mkEnableOption "Enable installer module";
    offline_installer = lib.mkEnableOption "Enable offline-installer";
  };

  # core = {
  #   steam.enable = lib.mkDefault true;
  #   virtualization.enable = lib.mkDefault false;
  #   installer = lib.mkDefault false;
  #   offline_installer = lib.mkDefault false;
  # };
}
