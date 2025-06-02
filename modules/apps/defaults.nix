# Provides reasonable defaults to get started... mainly
# stuff to ensure your system can reliably rebuild this flake
# in the future.

{ inputs, ... }: {
  apps.host-config = {
    tags = [ "defaults" ];
    nixos = { host, pkgs, lib, config, ... }: {
      nix = {
        registry = { nixpkgs.flake = inputs.nixpkgs; };
        settings = {
          trusted-users = [ "root" ];
          experimental-features = [ "nix-command" "flakes" ];
        };
      };
      boot = {
        consoleLogLevel = 0;
        initrd.verbose = false;
        initrd.availableKernelModules =
          [ "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" "sr_mod" ];

        loader = {
          systemd-boot = {
            enable = true;
            configurationLimit = 10;
            memtest86.enable = true;
            consoleMode = "max";
          };
          efi.canTouchEfiVariables = true;
          timeout = 10;
        };
        supportedFilesystems = [ "ntfs" ];
      };
      networking = {
        hostName = "${host.name}";
        useDHCP = lib.mkDefault true;
        networkmanager = {
          enable = true;
          plugins = with pkgs; [
            networkmanager-openconnect
            networkmanager-openvpn
            networkmanager-vpnc
          ];
          wifi = { powersave = false; };
        };
        nameservers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];
        firewall = {
          enable = true;
          allowedTCPPorts = [ 22 80 443 ];
        };
      };
      programs.nm-applet.enable = true;

      environment.systemPackages = with pkgs;
        [
          networkmanagerapplet
          ifwifi
          fuse-overlayfs
          podman-compose
          podman-tui
          podman
          inxi
          dmidecode
          htop
          gping
          httpie
          xh
        ] ++ lib.optionals (host.desktop != null) [ pods xorg.xhost ];

      hardware.nvidia-container-toolkit.enable =
        lib.elem "nvidia" config.services.xserver.videoDrivers;
      virtualisation = {
        podman = {
          defaultNetwork.settings = { dns_enabled = true; };
          autoPrune = {
            enable = true;
            flags = [ "--all" ];
          };
          dockerCompat = true;
          dockerSocket.enable = true;
          enable = true;
        };
      };
      services.resolved = {
        enable = true;
        dnssec = "yes";
        domains = [ "~." ];
        fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
        dnsovertls = "no";
      };
      services.openssh = {
        enable = true;
        allowSFTP = false;

        settings = {
          # Harden
          PasswordAuthentication = lib.mkDefault false;
          PermitRootLogin = lib.mkDefault "no";
          ChallengeResponseAuthentication = false;
          AllowTcpForwarding = "yes";
          X11Forwarding = false;
          AllowAgentForwarding = "yes";
          AllowStreamLocalForwarding = "no";
          AuthenticationMethods = "publickey";
          # Automatically remove stale sockets
          StreamLocalBindUnlink = "yes";
        };

        hostKeys = [{
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }];
      };
      console = { keyMap = "us"; };

      system.stateVersion = "25.05";
    };
    home = { home.stateVersion = "25.05"; };
    darwin = { system.stateVersion = 5; };
  };
  defaultTags = { defaults = true; };
}
