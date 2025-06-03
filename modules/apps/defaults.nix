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
    home = { host, pkgs, lib, config, ... }: {
      programs.ssh = {
        enable = true;

        addKeysToAgent = "1h";

        controlMaster = "auto";
        controlPath = "~/.ssh/sessions/%r@%h:%p";
        controlPersist = "10m";

        matchBlocks = {
          github = {
            host = "github.com";
            hostname = "ssh.github.com";
            user = "git";
            port = 443;
            identitiesOnly = true;
          };
        };
      };
      programs.neovim = {
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };

      services.ssh-agent.enable = true;
      home = {
        file.".face".source = lib.mkDefault ./face.png;
        packages = with pkgs; [
          gopass
          gopass-hibp
          gopass-summon-provider
          summon
          asciinema # Terminal recorder
          black # Code format Python
          bmon # Modern Unix `iftop`
          borgmatic
          chroma # Code syntax highlighter
          clinfo # Terminal OpenCL info
          czkawka # find duplicated files
          dconf2nix # Nix code from Dconf files
          debootstrap # Terminal Debian installer
          diffr # Modern Unix `diff`
          difftastic # Modern Unix `diff`
          dogdns # Modern Unix `dig`
          du-dust # Modern Unix `du`
          dua # Modern Unix `du`
          duf # Modern Unix `df`
          entr # Modern Unix `watch`
          fast-cli # Terminal fast.com
          fd # Modern Unix `find`
          fira-code
          fira-go
          font-awesome
          glow # Terminal Markdown renderer
          gping # Modern Unix `ping`
          hcloud
          hexyl # Modern Unix `hexedit`
          httpie # Terminal HTTP client
          hyperfine # Terminal benchmarking
          iperf3 # Terminal network benchmarking
          iw # Terminal WiFi info
          jiq # Modern Unix `jq`
          joypixels
          jpegoptim # Terminal JPEG optimizer
          lazygit # Terminal Git client
          liberation_ttf
          libva-utils # Terminal VAAPI info
          lurk # Modern Unix `strace`
          mdp # Terminal Markdown presenter
          moar # Modern Unix `less`
          mtdutils
          mtr # Modern Unix `traceroute`
          netdiscover # Modern Unix `arp`
          nethogs # Modern Unix `iftop`
          nixpkgs-review # Nix code review
          nodePackages.prettier # Code format
          noto-fonts-emoji
          nurl # Nix URL fetcher
          nyancat # Terminal rainbow spewing feline
          ollama # AI stuff
          optipng # Terminal PNG optimizer
          procs # Modern Unix `ps`
          prusa-slicer
          pwgen # password generator
          quilt # Terminal patch manager
          ripgrep # Modern Unix `grep`
          rustfmt # Code format Rust
          shellcheck # Code lint Shell
          shfmt # Code format Shell
          source-serif
          speedtest-go # Terminal speedtest.net
          strongswan
          tldr # Modern Unix `man`
          tokei # Modern Unix `wc` for code
          ubuntu_font_family
          victor-mono
          vscode # GUI Code editor
          wavemon # Terminal WiFi monitor
          work-sans
          yq-go # Terminal `jq` for YAML
          yubikey-manager
          bitwise # cli tool for bit / hex manipulation
          dysk # disk information
          eza # ls replacement
          entr # perform action when file change
          fd # find replacement
          file # Show file information
          hevi # hex viewer
          htop
          mpv # video player
          ncdu # disk space
          programmer-calculator
          shfmt # bash formatter
          swappy # snapshot editing tool
          xdg-utils
          xxd
          fastfetch
          devenv
          cloudflared
          efibootmgr
          fishPlugins.done
          fishPlugins.fzf
          fishPlugins.forgit
          fishPlugins.hydro
          fzf
          fishPlugins.grc
          grc
          viddy
          just
          tmux
          gdu
          nerd-fonts.fira-code
          nerd-fonts.symbols-only
          corefonts
          fira
          font-awesome
          liberation_ttf
          noto-fonts-emoji
          noto-fonts-monochrome-emoji
          source-serif
          symbola
          work-sans
          colordiff

          cbonsai # terminal screensaver
          cmatrix
          pipes # terminal screensaver
          sl
          tty-clock # cli clock
        ];
        sessionPath = [ "$HOME/.local/bin" ];
        sessionVariables = {
          EDITOR = "nvim";
          SYSTEMD_EDITOR = "nvim";
          VISUAL = "nvim";
          NH_FLAKE = "${config.home.homeDirectory}/dev/nix";
          PAGER = "moar";
        };
        activation.report-changes = config.lib.dag.entryAnywhere ''
          ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
        '';
      };
      systemd.user.tmpfiles.rules = [
        "d ${config.home.homeDirectory}/.ssh/sessions 0755 ${host.username} ${host.username} - -"
      ];

      services = {
        gpg-agent = {
          enable = true;
          pinentry.package = lib.mkDefault pkgs.pinentry-curses;
        };
      };

      # Nicely reload system units when changing configs
      systemd.user.startServices = "sd-switch";

      home.stateVersion = "25.05";
    };
    darwin = { system.stateVersion = 5; };
  };
  defaultTags = { defaults = lib.mkDefault true; };
}
