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
      nix = {
        registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
        settings = {
          auto-optimise-store = true;
          substituters =
            [ "https://cache.nixos.org" "https://cache.nixos.org/" ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          ];
          experimental-features = [ "nix-command" "flakes" ];
          # Avoid unwanted garbage collection when using nix-direnv
          keep-outputs = true;
          keep-derivations = true;
          warn-dirty = false;
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
          # jiq # Modern Unix `jq`
          # joypixels
          # jpegoptim # Terminal JPEG optimizer
          # lazygit # Terminal Git client
          # liberation_ttf
          # libva-utils # Terminal VAAPI info
          # lurk # Modern Unix `strace`
          # mdp # Terminal Markdown presenter
          # moar # Modern Unix `less`
          # mtdutils
          # mtr # Modern Unix `traceroute`
          # netdiscover # Modern Unix `arp`
          # nethogs # Modern Unix `iftop`
          # nixpkgs-review # Nix code review
          # nodePackages.prettier # Code format
          # noto-fonts-emoji
          # nurl # Nix URL fetcher
          # nyancat # Terminal rainbow spewing feline
          # ollama # AI stuff
          # optipng # Terminal PNG optimizer
          # procs # Modern Unix `ps`
          # prusa-slicer
          # pwgen # password generator
          # quilt # Terminal patch manager
          # ripgrep # Modern Unix `grep`
          # rustfmt # Code format Rust
          # shellcheck # Code lint Shell
          # shfmt # Code format Shell
          # source-serif
          # speedtest-go # Terminal speedtest.net
          # strongswan
          # tldr # Modern Unix `man`
          # tokei # Modern Unix `wc` for code
          # ubuntu_font_family
          # victor-mono
          # vscode # GUI Code editor
          # wavemon # Terminal WiFi monitor
          # work-sans
          # yq-go # Terminal `jq` for YAML
          # yubikey-manager
          # bitwise # cli tool for bit / hex manipulation
          # dysk # disk information
          # eza # ls replacement
          # entr # perform action when file change
          # fd # find replacement
          # file # Show file information
          # hevi # hex viewer
          # htop
          # mpv # video player
          # ncdu # disk space
          # programmer-calculator
          # shfmt # bash formatter
          # swappy # snapshot editing tool
          # xdg-utils
          # xxd
          # fastfetch
          # devenv
          # cloudflared
          # efibootmgr
          # fishPlugins.done
          # fishPlugins.fzf
          # fishPlugins.forgit
          # fishPlugins.hydro
          # fzf
          # fishPlugins.grc
          # grc
          # viddy
          # just
          # tmux
          # gdu
          # nerd-fonts.fira-code
          # nerd-fonts.symbols-only
          # corefonts
          # fira
          # font-awesome
          # liberation_ttf
          # noto-fonts-emoji
          # noto-fonts-monochrome-emoji
          # source-serif
          # symbola
          # work-sans
          # colordiff

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

      programs = {
        git = {
          signing = { signByDefault = true; };
          aliases = {
            squash-all =
              ''!f(){ git reset $(git commit-tree HEAD^{tree} "$@");};f'';
          };
        };
        lazygit = {
          enable = true;
          settings = { gui.theme = { lightTheme = false; }; };
        };

        starship = {
          enable = true;
          enableZshIntegration = true;
          enableFishIntegration = true;
          settings = {
            add_newline = false;
            command_timeout = 1000;
            time = { disabled = true; };
            format = lib.concatStrings [
              "$os"
              "$username"
              "$hostname"
              "$directory"
              "$c"
              "$dotnet"
              "$golang"
              "$java"
              "$lua"
              "$nodejs"
              "$ruby"
              "$rust"
              "$perl"
              "$php"
              "$python"
              "$package"
              "$git_branch"
              "$git_status"
              "$container"
              "$direnv"
              "$nix_shell"
              "$cmd_duration"
              "$jobs"
              "$shlvl"
              "$status"
              "$character"
            ];
            os = {
              disabled = false;
              format = "$symbol";
              style = "";
            };
            os.symbols = {
              AlmaLinux = "[](fg:text bg:surface1)";
              Alpine = "[](fg:blue bg:surface1)";
              Amazon = "[](fg:peach bg:surface1)";
              Android = "[](fg:green bg:surface1)";
              Arch = "[󰣇](fg:sapphire bg:surface1)";
              Artix = "[](fg:sapphire bg:surface1)";
              CentOS = "[](fg:mauve bg:surface1)";
              Debian = "[](fg:red bg:surface1)";
              DragonFly = "[](fg:teal bg:surface1)";
              EndeavourOS = "[](fg:mauve bg:surface1)";
              Fedora = "[](fg:blue bg:surface1)";
              FreeBSD = "[](fg:red bg:surface1)";
              Garuda = "[](fg:sapphire bg:surface1)";
              Gentoo = "[](fg:lavender bg:surface1)";
              Illumos = "[](fg:peach bg:surface1)";
              Kali = "[](fg:blue bg:surface1)";
              Linux = "[](fg:yellow bg:surface1)";
              Macos = "[](fg:text bg:surface1)";
              Manjaro = "[](fg:green bg:surface1)";
              Mariner = "[](fg:sky bg:surface1)";
              MidnightBSD = "[](fg:yellow bg:surface1)";
              Mint = "[󰣭](fg:teal bg:surface1)";
              NetBSD = "[](fg:peach bg:surface1)";
              NixOS = "[](fg:sky bg:surface1)";
              OpenBSD = "[](fg:yellow bg:surface1)";
              openSUSE = "[](fg:green bg:surface1)";
              OracleLinux = "[󰌷](fg:red bg:surface1)";
              Pop = "[](fg:sapphire bg:surface1)";
              Raspbian = "[](fg:maroon bg:surface1)";
              Redhat = "[](fg:red bg:surface1)";
              RedHatEnterprise = "[](fg:red bg:surface1)";
              RockyLinux = "[](fg:green bg:surface1)";
              Solus = "[](fg:blue bg:surface1)";
              SUSE = "[](fg:green bg:surface1)";
              Ubuntu = "[](fg:peach bg:surface1)";
              Unknown = "[](fg:text bg:surface1)";
              Void = "[](fg:green bg:surface1)";
              Windows = "[󰖳](fg:sky bg:surface1)";
            };
            username = {
              aliases = {
                "ion" = "󰝴";
                "dweissengruber" = "󰝴";
                "root" = "󰱯";
              };
              format = "[ $user]($style)";
              show_always = true;
              style_user = "fg:green bg:surface2";
              style_root = "fg:red bg:surface2";
            };
            hostname = {
              disabled = false;
              style = "bg:overlay0 fg:red";
              ssh_only = false;
              ssh_symbol = " 󰖈";
              format =
                "[ $hostname]($style)[$ssh_symbol](bg:overlay0 fg:maroon)";
            };
            directory = {
              format = "[ $path]($style)[$read_only]($read_only_style)";
              home_symbol = "";
              read_only = " 󰈈";
              read_only_style = "bold fg:crust bg:mauve";
              style = "fg:base bg:mauve";
              truncate_to_repo = false;
              truncation_length = 3;
              truncation_symbol = "…/";
            };
            # Shorten long paths by text replacement. Order matters
            directory.substitutions = {
              "Desktop" = "";
              "dev" = "";
              "notes" = "󰈙";
              "Downloads" = "󰉍";
              "Music" = "󰎄";
              "Pictures" = "";
              "Public" = "";
              "Vault" = "󰌿";
              "tmp" = "󱪃";
              "nix" = "󱄅";
            };
            # Languages
            c = {
              format = "[ $symbol]($style)";
              style = "fg:base bg:peach";
              symbol = "";
            };
            dotnet = {
              format = "[ $symbol]($style)";
              style = "fg:base bg:peach";
              symbol = "";
            };
            golang = {
              format = "[ $symbol]($style)";
              style = "fg:base bg:peach";
              symbol = "";
            };
            java = {
              format = "[ $symbol]($style)";
              style = "fg:base bg:peach";
              symbol = "󰬷";
            };
            lua = {
              format = "[ $symbol]($style)";
              style = "fg:base bg:peach";
              symbol = "";
            };
            nodejs = {
              format = "[ $symbol]($style)";
              style = "fg:base bg:peach";
              symbol = "";
            };
            perl = {
              format = "[ $symbol]($style)";
              style = "fg:base bg:peach";
              symbol = "";
            };
            php = {
              format = "[ $symbol]($style)";
              style = "fg:base bg:peach";
              symbol = "󰌟";
            };
            python = {
              format = "[ $symbol]($style)";
              style = "fg:base bg:peach";
              symbol = "";
            };
            ruby = {
              format = "[ $symbol]($style)";
              style = "fg:base bg:peach";
              symbol = "";
            };
            rust = {
              format = "[ $symbol]($style)";
              style = "fg:base bg:peach";
              symbol = "";
            };
            package = {
              format = "[ $version]($style)";
              style = "fg:base bg:peach";
              version_format = "$raw";
            };
            git_branch = {
              format = "[ $symbol $branch]($style)";
              style = "fg:base bg:peach";
              symbol = "";
            };
            git_status = {
              format = "[ $all_status$ahead_behind]($style)";
              style = "fg:base bg:yellow";
            };
            # "Shells"
            container = {
              format = "[ $symbol $name]($style)";
              style = "fg:base bg:teal";
            };
            direnv = {
              disabled = false;
              format = "[ $loaded]($style)";
              allowed_msg = "";
              not_allowed_msg = "";
              denied_msg = "";
              loaded_msg = "󰐍";
              unloaded_msg = "󰙧";
              style = "fg:base bg:teal";
              symbol = "";
            };
            nix_shell = {
              format = "[ $symbol]($style)";
              style = "fg:base bg:teal";
              symbol = "󱄅";
            };
            cmd_duration = {
              format = "[  $duration]($style)";
              min_time = 2500;
              min_time_to_notify = 60000;
              show_notifications = false;
              style = "fg:base bg:teal";
            };
            jobs = {
              format = "[ $symbol $number]($style)";
              style = "fg:base bg:teal";
              symbol = "󰣖";
            };
            shlvl = {
              disabled = false;
              format = "[ $symbol]($style)";
              repeat = false;
              style = "fg:surface1 bg:teal";
              symbol = "󱆃";
              threshold = 3;
            };
            status = {
              disabled = false;
              format = "$symbol";
              map_symbol = true;
              pipestatus = true;
              style = "";
              symbol = "[  $status](fg:red bg:pink)";
              success_symbol = "";
              not_executable_symbol = "[  $common_meaning](fg:red bg:pink)";
              not_found_symbol = "[ 󰩌 $common_meaning](fg:red bg:pink)";
              sigint_symbol = "[  $signal_name](fg:red bg:pink)";
              signal_symbol = "[ ⚡ $signal_name](fg:red bg:pink)";
            };
            character = {
              disabled = false;
              format = "$symbol";
              error_symbol = ''

                [➜](fg:yellow) '';
              success_symbol = ''

                [➜](fg:blue) '';
            };
          };
        };
        yazi = {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
          settings = {
            manager = {
              show_hidden = false;
              show_symlink = true;
              sort_by = "natural";
              sort_dir_first = true;
              sort_sensitive = false;
              sort_reverse = false;
            };
          };
        };
        fzf = {
          enable = true;

          enableZshIntegration = true;

          defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
          fileWidgetOptions = [
            "--preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'"
          ];
          changeDirWidgetCommand =
            "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
          changeDirWidgetOptions =
            [ "--preview 'eza --tree --color=always {} | head -200'" ];

          ## Theme
          defaultOptions = [
            "--color=fg:-1,fg+:#FBF1C7,bg:-1,bg+:#282828"
            "--color=hl:#98971A,hl+:#B8BB26,info:#928374,marker:#D65D0E"
            "--color=prompt:#CC241D,spinner:#689D6A,pointer:#D65D0E,header:#458588"
            "--color=border:#665C54,label:#aeaeae,query:#FBF1C7"
            "--border='double' --border-label='' --preview-window='border-sharp' --prompt='> '"
            "--marker='>' --pointer='>' --separator='─' --scrollbar='│'"
            "--info='right'"
          ];
        };
        cava = {
          enable = true;

          settings = {
            general = {
              autosens = 1;
              overshoot = 0;
            };

            color = {
              gradient = 1;
              gradient_count = 8;

              gradient_color_1 = "'#99991a'";
              gradient_color_2 = "'#a28e00'";
              gradient_color_3 = "'#ab8200'";
              gradient_color_4 = "'#b37400'";
              gradient_color_5 = "'#bb6600'";
              gradient_color_6 = "'#c25400'";
              gradient_color_7 = "'#c8400d'";
              gradient_color_8 = "'#cd231d'";
            };
          };
        };
        atuin = {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
          settings = {
            auto_sync = true;
            dialect = "uk";
            show_preview = true;
            filter_mode_shell_up_key_binding = "directory";
            style = "compact";
            sync_frequency = "1h";
            sync_address = "https://api.atuin.sh";
            update_check = false;
          };
        };
        bat = {
          enable = true;
          extraPackages = with pkgs.bat-extras; [ batwatch prettybat ];
        };
        bottom = {
          enable = true;
          settings = {
            colors = {
              high_battery_color = "green";
              medium_battery_color = "yellow";
              low_battery_color = "red";
            };
            disk_filter = {
              is_list_ignored = true;
              list = [ "/dev/loop" ];
              regex = true;
              case_sensitive = false;
              whole_word = false;
            };
            flags = {
              dot_marker = false;
              enable_gpu_memory = true;
              group_processes = true;
              hide_table_gap = true;
              mem_as_value = true;
              tree = true;
            };
          };
        };
        dircolors = {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
        };
        direnv = {
          enable = true;
          enableBashIntegration = true;
          nix-direnv = { enable = true; };
        };
        zoxide = {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
          # Replace cd with z and add cdi to access zi
          options = [ "--cmd cd" ];
        };
        zsh = { enable = true; };
        fish = {
          enable = true;
          shellAliases = {
            cat = "bat --paging=never --style=plain";
            htop =
              "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
            ip = "ip --color --brief";
            less = "bat --paging=always";
            more = "bat --paging=always";
            top =
              "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
            tree = "exa --tree";
          };
        };
        gh = {
          enable = true;
          extensions = with pkgs; [ gh-markdown-preview ];
          settings = {
            editor = "nvim";
            git_protocol = "ssh";
            prompt = "enabled";
          };
        };
        git = {
          enable = true;
          userName = "${host.username}";
          userEmail = "${host.email}";
          delta = {
            enable = true;
            options = {
              features = "decorations";
              navigate = true;
              side-by-side = true;
            };
          };
          aliases = {
            lg =
              "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          };
          extraConfig = {
            push = {
              default = "current";
              autoSetupRemote = true;
            };
            pull = { rebase = true; };
            init = { defaultBranch = "main"; };
          };
          ignores = [ "*.log" "*.out" ".DS_Store" "bin/" "dist/" "result" ];
        };
        gpg = {
          enable = true;
          scdaemonSettings = {
            disable-ccid = true;
            pcsc-shared = true;
            disable-application = "piv";
          };
        };
        home-manager.enable = true;
        info.enable = true;
        jq.enable = true;
      };

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
