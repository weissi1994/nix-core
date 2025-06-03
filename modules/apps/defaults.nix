# Provides reasonable defaults to get started... mainly
# stuff to ensure your system can reliably rebuild this flake
# in the future.

{ inputs, lib, ... }: {
  apps.host-config = {
    tags = [ "defaults" ];
    nixos = { host, pkgs, lib, config, ... }: {
      nix = {
        registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
        nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}")
          config.nix.registry;

        optimise.automatic = true;
        settings = {
          auto-optimise-store = true;
          # Avoid unwanted garbage collection when using nix-direnv
          keep-outputs = true;
          keep-derivations = true;

          warn-dirty = false;
          trusted-users = [ "@wheel" ];
          experimental-features = [ "nix-command" "flakes" ];
          substituters =
            [ "https://cache.nixos.org" "https://cache.nixos.org/" ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          ];
        };
      };

      services.envfs.enable = true;

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
        dnssec = "true";
        domains = [ "~." ];
        fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
        dnsovertls = "false";
      };
      programs.nh = {
        enable = true;
        clean = {
          enable = true;
          extraArgs = "--keep-since 14d --keep 10";
        };
        flake = "/home/${host.username}/dev/nix";
      };

      hardware.gpgSmartcards.enable = true;
      programs.ssh.startAgent = false;
      services = {
        pcscd = {
          enable = true;
          plugins = [ pkgs.libykneomgr ];
        };
      };
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        enableExtraSocket = true;
        settings = {
          default-cache-ttl = 1800;
          max-cache-ttl = 28800;
          default-cache-ttl-ssh = 1800;
          max-cache-ttl-ssh = 7200;
        };
        pinentryPackage = lib.mkDefault pkgs.pinentry-curses;
      };

      security = {
        pam = {
          u2f.enable = true;
          u2f.settings.cue = true;

          services = {
            login.u2fAuth = true;
            gdm-password.u2fAuth = true;
            sudo.u2fAuth = true;
            swaylock = { };
            hyprlock = { };
          };
        };
        rtkit.enable = true;

        # auditd.enable = true;
        # audit.enable = lib.mkDefault true;
        # audit.rules = [
        #   "-a exit,always -F arch=b64 -S execve"
        # ];
        polkit.enable = true;

        sudo = {
          enable = true;
          execWheelOnly = true;
          extraRules = [{
            commands = [{
              command = "ALL";
              options = [ "NOPASSWD" ];
            }];
            groups = [ "wheel" ];
          }];
        };
      };
      boot.supportedFilesystems = lib.mkForce [
        "btrfs"
        "bcachefs"
        "cifs"
        "f2fs"
        "jfs"
        "ntfs"
        "reiserfs"
        "vfat"
        "xfs"
      ];

      services.udev.packages = with pkgs; [
        android-udev-rules
        libu2f-host
        yubikey-personalization
      ];

      # Works around https://github.com/NixOS/nixpkgs/issues/103746
      systemd.services."getty@tty1".enable = false;
      systemd.services."autovt@tty1".enable = false;
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
      environment = {
        # Eject nano and perl from the system
        defaultPackages = with pkgs;
          lib.mkForce [ gitMinimal home-manager deploy-rs vim rsync ];
        systemPackages = with pkgs; [
          file
          wget
          curl
          git
          devenv
          aichat
          pinentry-curses
          imagemagickBig
          pinentry-gnome3
          gettext
          age
          bc
          zip
          cachix
          comma
          nh
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
          nix-output-monitor
          nvd
          gnupg
          libfido2
          libu2f-host
          yubikey-personalization
          vulnix
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

      programs = {
        nix-ld.enable = true;
        zsh = {
          enable = true;
          enableCompletion = true;
          autosuggestions = {
            enable = true;
            strategy = [ "completion" "match_prev_cmd" ];
          };
          syntaxHighlighting.enable = true;
        };
      };

      services.fwupd.enable = true;

      systemd.tmpfiles.rules = [
        "d /nix/var/nix/profiles/per-user/${host.username} 0755 ${host.username} root"
        "d /mnt/${host.username} 0755 ${host.username} ${host.username}"
      ];

      system.stateVersion = "25.05";
    };
    home = { home.stateVersion = "25.05"; };
    darwin = { system.stateVersion = 5; };
  };
  defaultTags = { defaults = lib.mkDefault true; };
}
