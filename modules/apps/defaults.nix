# Provides reasonable defaults to get started... mainly
# stuff to ensure your system can reliably rebuild this flake
# in the future.

{ inputs, lib, ... }:
{
  apps.host-config = {
    tags = [ "defaults" ];
    nixos =
      {
        host,
        pkgs,
        lib,
        config,
        ...
      }:
      {
        nix = {
          registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
          nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

          optimise.automatic = true;
          settings = {
            auto-optimise-store = true;
            # Avoid unwanted garbage collection when using nix-direnv
            keep-outputs = true;
            keep-derivations = true;

            warn-dirty = false;
            trusted-users = [ "@wheel" ];
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            substituters = [
              "https://cache.nixos.org"
              "https://cache.nixos.org/"
            ];
            trusted-public-keys = [
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            ];
          };
        };

        boot = {
          consoleLogLevel = 0;
          initrd.verbose = false;
          initrd.systemd.enable = true;
          initrd.availableKernelModules = [
            "nvme"
            "xhci_pci"
            "ahci"
            "usbhid"
            "sd_mod"
            "sr_mod"
          ];

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
            wifi = {
              powersave = false;
            };
          };
          nameservers = [
            "1.1.1.1"
            "8.8.8.8"
            "8.8.4.4"
          ];
          firewall = {
            enable = true;
            allowedTCPPorts = [
              22
              80
              443
            ];
          };
        };

        hardware.nvidia-container-toolkit.enable = lib.elem "nvidia" config.services.xserver.videoDrivers;
        virtualisation = {
          podman = {
            defaultNetwork.settings = {
              dns_enabled = true;
            };
            autoPrune = {
              enable = true;
              flags = [ "--all" ];
            };
            dockerCompat = true;
            dockerSocket.enable = true;
            enable = true;
          };
        };

        hardware.gpgSmartcards.enable = true;
        services = {
          fwupd.enable = true;
          envfs.enable = true;
          resolved = {
            enable = true;
            dnssec = "true";
            domains = [ "~." ];
            fallbackDns = [
              "1.1.1.1"
              "8.8.8.8"
            ];
            dnsovertls = "false";
          };
          pcscd = {
            enable = true;
            plugins = [ pkgs.libykneomgr ];
          };
          udev.packages = with pkgs; [
            android-udev-rules
            libu2f-host
            yubikey-personalization
          ];
          openssh = {
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

            hostKeys = [
              {
                path = "/etc/ssh/ssh_host_ed25519_key";
                type = "ed25519";
              }
            ];
          };
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
            extraRules = [
              {
                commands = [
                  {
                    command = "ALL";
                    options = [ "NOPASSWD" ];
                  }
                ];
                groups = [ "wheel" ];
              }
            ];
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

        console = {
          keyMap = "us";
        };
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
          nh = {
            enable = true;
            clean = {
              enable = true;
              extraArgs = "--keep-since 14d --keep 10";
            };
            flake = "/home/${host.username}/dev/nix";
          };
          ssh.startAgent = false;
          gnupg.agent = {
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

        systemd = {
          # Works around https://github.com/NixOS/nixpkgs/issues/103746
          services."getty@tty1".enable = false;
          services."autovt@tty1".enable = false;
          tmpfiles.rules = [
            "d /nix/var/nix/profiles/per-user/${host.username} 0755 ${host.username} root"
            "d /mnt/${host.username} 0755 ${host.username} ${host.username}"
          ];
        };

        system.stateVersion = "25.05";
      };
    home =
      {
        host,
        pkgs,
        lib,
        config,
        ...
      }:
      {
        nix = {
          registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
          settings = {
            auto-optimise-store = true;
            substituters = [
              "https://cache.nixos.org"
              "https://cache.nixos.org/"
            ];
            trusted-public-keys = [
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            ];
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            # Avoid unwanted garbage collection when using nix-direnv
            keep-outputs = true;
            keep-derivations = true;
            warn-dirty = false;
          };
        };

        services = {
          ssh-agent.enable = true;
          gpg-agent = {
            enable = true;
            pinentry.package = lib.mkDefault pkgs.pinentry-curses;
          };
        };
        home = {
          file.".face".source = lib.mkDefault ./files/face.png;
          packages = with pkgs; [
            ydiff
            asciinema # Terminal recorder
            bitwise # cli tool for bit / hex manipulation
            black # Code format Python
            bmon # Modern Unix `iftop`
            borgmatic
            cava # for cli equealizer #unixporn
            cbonsai # terminal screensaver
            choose # modern cut
            chroma # Code syntax highlighter
            clinfo # Terminal OpenCL info
            cloudflared
            cmatrix
            colordiff
            czkawka # find duplicated files
            dconf2nix # Nix code from Dconf files
            debootstrap # Terminal Debian installer
            devenv
            diffr # Modern Unix `diff`
            difftastic # Modern Unix `diff`
            dogdns # Modern Unix `dig`
            du-dust # Modern Unix `du`
            dua # Modern Unix `du`
            duf # Modern Unix `df`
            dysk # disk information
            efibootmgr
            entr # perform action when file change
            eza # ls replacement
            fast-cli # Terminal fast.com
            fastfetch
            fd # Modern Unix `find`
            file # Show file information
            fira-code
            fira-go
            fish
            fishPlugins.done
            fishPlugins.forgit
            fishPlugins.fzf
            fishPlugins.grc
            fishPlugins.hydro
            fzf
            gdu
            glow # Terminal Markdown renderer
            gnumake
            gopass
            gopass-hibp
            gopass-summon-provider
            gping # Modern Unix `ping`
            grc
            hcloud
            hevi # hex viewer
            hexyl # Modern Unix `hexedit`
            htop
            httpie # Terminal HTTP client
            hyperfine # Terminal benchmarking
            iperf3 # Terminal network benchmarking
            iw # Terminal WiFi info
            jless # json less
            just
            lazygit # Terminal Git client
            liberation_ttf
            libva-utils # Terminal VAAPI info
            lurk # Modern Unix `strace`
            mdp # Terminal Markdown presenter
            meslo-lgs-nf
            moar # Modern Unix `less`
            mpv # video player
            mtdutils
            mtr # Modern Unix `traceroute`
            ncdu # disk space
            netdiscover # Modern Unix `arp`
            nethogs # Modern Unix `iftop`
            pipes # terminal screensaver
            procs # Modern Unix `ps`
            programmer-calculator
            pwgen # password generator
            ripgrep # Modern Unix `grep`
            sd # modern sed
            seahorse
            shfmt # bash formatter
            sl
            speedtest-go # Terminal speedtest.net
            summon
            swappy # snapshot editing tool
            tldr # Modern Unix `man`
            tmux
            tokei # Modern Unix `wc` for code
            tty-clock # cli clock
            viddy
            wavemon # Terminal WiFi monitor
            work-sans
            xdg-utils
            xxd
            yank # Yank terminal output to clipboard.
            yq-go # Terminal `jq` for YAML
            yubikey-manager
          ];
          sessionPath = [ "$HOME/.local/bin" ];
          sessionVariables = {
            EDITOR = "nvim";
            SYSTEMD_EDITOR = "nvim";
            VISUAL = "nvim";
            NH_FLAKE = "git+https://gitlab.n0de.biz/daniel/nix?ref=main";
            PAGER = "moar";
          };
          activation.report-changes = config.lib.dag.entryAnywhere ''
            ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
          '';
        };

        programs = {
          ssh = {
            enable = true;

            addKeysToAgent = "1h";

            controlMaster = "auto";
            controlPath = "~/.ssh/sessions/%C";
            controlPersist = "10m";

            matchBlocks = {
              "*" = {
                user = "${host.username}";
                identityFile = "~/.ssh/id_rsa_yubikey.pub";
              };
              github = {
                host = "github.com";
                hostname = "ssh.github.com";
                user = "git";
                port = 443;
                identitiesOnly = true;
              };
              "gitlab.n0de.biz" = {
                hostname = "git.n0de.biz";
              };
              "git.n0de.biz" = {
                proxyCommand = "/etc/profiles/per-user/${host.username}/bin/cloudflared access ssh --hostname %h";
                user = "git";
                identityFile = "~/.ssh/id_rsa_yubikey.pub";
              };
            };
          };
          neovim = {
            defaultEditor = true;
            viAlias = true;
            vimAlias = true;
          };
          lazygit = {
            enable = true;
            settings = {
              gui.theme = {
                lightTheme = false;
              };
            };
          };
          nix-index = {
            enable = true;
            enableBashIntegration = false;
            enableZshIntegration = false;
            enableFishIntegration = false;
          };
          command-not-found.enable = true;

          fish = {
            enable = true;
            shellInit = # fish
              ''
                set -q KREW_ROOT; and set -gx PATH $PATH $KREW_ROOT/.krew/bin; or set -gx PATH $PATH $HOME/.krew/bin

                # Set PATH for fish
                set -gx PATH $PATH /run/current-system/sw/bin
                set -gx PATH $PATH $HOME/.local/bin
                set -gx PATH $PATH $HOME/.cargo/bin
                set -gx PATH $PATH $HOME/.yarn/bin
                set -gx PATH $PATH $HOME/go/bin
                set -gx PATH $PATH $HOME/bin

                bind \e\[1\;5C forward-bigword
                bind \e\[1\;5D backward-bigword

                set em_confused "¯\_(⊙︿⊙)_/¯"
                set em_crying ಥ_ಥ
                set em_cute_bear "ʕ•ᴥ•ʔ"
                set em_cute_face "(｡◕‿◕｡)"
                set em_excited "☜(⌒▽⌒)☞"
                set em_fisticuffs "ლ(｀ー´ლ)"
                set em_fliptable "(╯°□°）╯︵ ┻━┻"
                set em_table_flip_person "ノ┬─┬ノ ︵ ( \o°o)\\"
                set em_person_unflip_table "┬──┬◡ﾉ(° -°ﾉ)"
                set em_happy "ヽ(´▽\`)/"
                set em_innocent "ʘ‿ʘ"
                set em_kirby "⊂(◉‿◉)つ"
                set em_lennyface "( ͡° ͜ʖ ͡°)"
                set em_lion "°‿‿°"
                set em_muscleflex "ᕙ(⇀‸↼‶)ᕗ"
                set em_muscleflex2 "ᕦ(∩◡∩)ᕤ"
                set em_perky "(\`・ω・\´)"
                set em_piggy "( ́・ω・\`)"
                set em_shrug "¯\_(ツ)_/¯"
                set em_point_right "(☞ﾟヮﾟ)☞"
                set em_point_left "☜(ﾟヮﾟ☜)"
                set em_magic "╰(•̀ 3 •́)━☆ﾟ.*･｡ﾟ"
                set em_shades "(•_•)\n( •_•)>⌐■-■\n(⌐■_■)"
                set em_disapprove ಠ_ಠ
                set em_wink "ಠ‿↼"
                set em_facepalm "(－‸ლ)"
                set em_hataz_gon_hate "ᕕ( ᐛ )ᕗ"
                set em_salute "(￣^￣)ゞ"

                set kube_now "--force --grace-period 0"
                # gpg-connect-agent updatestartuptty /bye >/dev/null
              '';
            shellInitLast = # fish
              ''
                function fish_greeting
                  fastfetch
                end
              '';
            plugins = [
              {
                name = "grc";
                inherit (pkgs.fishPlugins.grc) src;
              }
              {
                name = "fzf";
                inherit (pkgs.fishPlugins.fzf) src;
              }
              {
                name = "colored-man-pages";
                inherit (pkgs.fishPlugins.colored-man-pages) src;
              }
              {
                name = "plugin-git";
                inherit (pkgs.fishPlugins.plugin-git) src;
              }
              {
                name = "autopair";
                inherit (pkgs.fishPlugins.autopair) src;
              }
              {
                name = "sponge";
                inherit (pkgs.fishPlugins.sponge) src;
              }
              {
                name = "humantime-fish";
                inherit (pkgs.fishPlugins.humantime-fish) src;
              }
            ];
            shellAliases = {
              cat = "bat --paging=never --style=plain";
              htop = "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
              ip = "ip --color --brief";
              less = "bat --paging=always";
              more = "bat --paging=always";
              top = "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
              tree = "exa --tree";
              l = "exa -hF --color=always --icons --sort=created --group-directories-first";
              ls = "exa -lhF --color=always --icons --sort=created --group-directories-first";
              lst = "exa -lahRT --color=always --icons --sort=created --group-directories-first";
              nt = ''vim "+ObsidianWorkspace Private" +ObsidianToday ~/notes/TODO.md'';

              trip = "sudo trip --tui-theme-colors settings-dialog-bg-color=Black,help-dialog-bg-color=Black";
              yless = "jless --yaml";

              lg = "lazygit";
              ag = "rg";
              # ssh = "kitten ssh";
              ufwlog = ''journalctl -k | grep "IN=.*OUT=.*" | less'';
              sshold = "ssh -c 3des-cbc,aes256-cbc -oKexAlgorithms=+diffie-hellman-group1-sha1 ";
              colour = "grc -es --colour=auto";
              as = "colour as";
              configure = "colour ./configure";
              diff = "colour diff";
              docker = "colour docker";
              gcc = "colour gcc";
              stat = "colour stat";
              head = "colour head";
              ifconfig = "colour ifconfig";
              ld = "colour ld";
              make = "colour make";
              mount = "colour mount";
              netstat = "colour netstat";
              ping = "colour ping";
              ps = "colour ps";
              tcpdump = "sudo grc -es --colour=on tcpdump";
              ss = "colour ss";
              tail = "colour tail";
              traceroute = "colour traceroute";
              kernlog = "sudo journalctl -xe -k -b | less";
              syslog = "sudo journalctl -xef";

              # Git aliases
              gb = "git branch";
              gbc = "git checkout -b";
              gbs = "git show-branch";
              gbS = "git show-branch -a";
              gc = "git commit --verbose";
              gca = "git commit --verbose --all";
              gcm = "g3l -m";
              gcf = "git commit --amend --reuse-message HEAD";
              gcF = "git commit --verbose --amend";
              gcR = ''git reset "HEAD^"'';
              gcs = "git show";
              gdi = ''git status --porcelain --short --ignored | sed -n "s/^!! //p"'';
              gg = "git log --oneline --graph --color --all --decorate";
              gia = "git add";
              giA = "git add --patch";
              giu = "git add --update";
              gid = "git diff --no-ext-diff --cached";
              giD = "git diff --no-ext-diff --cached --word-diff";
              gir = "git reset";
              giR = "git reset --patch";
              gix = "git rm -r --cached";
              giX = "git rm -rf --cached";
              gld = "ydiff -ls -w0 --wrap";
              glc = "git shortlog --summary --numbered";
              gm = "git merge";
              gmc = "git merge --continue";
              gmC = "git merge --no-commit";
              gmF = "git merge --no-ff";
              gma = "git merge --abort";
              gmt = "git mergetool";
              gp = "git push";
              gptst = ''git push -o ci.variable="ALWAYS_RUN_TEST=true"'';
              gpmr = "push -o merge_request.create -o merge_request.target=development";
              gpmrm = "push -o merge_request.create -o merge_request.target=development -o merge_request.merge_when_pipeline_succeeds";
              gpf = "git push --force";
              gpa = "git push --all";
              gpA = "git push --all && git push --tags";
              gpc = ''git push --set-upstream origin "$(git-branch-current 2> /dev/null)"'';
              gpp = ''git pull origin "$(git-branch-current 2> /dev/null)" && git push origin "$(git-branch-current 2> /dev/null)"'';
              gwd = "git diff --no-ext-diff";
              gwD = "git diff --no-ext-diff --word-diff";
              gwr = "git reset --soft";
              gwR = "git reset --hard";
              gwc = "git clean -n";
              gwC = "git clean -f";
              gwx = "git rm -r";
              gwX = "git rm -rf";
            };
            functions = {
              # Note taking
              k = {
                wraps = "kubectl";
                body = ''
                  kubectl $argv
                '';
              };

              ko = {
                wraps = "kubectl";
                body = ''
                  kubectl --dry-run=client -o yaml $argv
                '';
              };

              ykreset = {
                body = ''
                  gpg-connect-agent updatestartuptty /bye; killall -9 gpg-agent; sudo systemctl restart pcscd.service
                '';
              };

              restart-dockers = {
                body = ''
                  sudo systemctl list-units --output json | jq -r '.[]|select(.unit | startswith("podman-")) | select(.unit | startswith("podman-prune") | not) | select(.unit | startswith("podman-gitlab") | not) | select(.unit | startswith("podman-traefik") | not) | .unit' | xargs sudo systemctl restart
                  sudo systemctl restart podman-gitlab.service;
                  sudo systemctl restart podman-traefik.service;
                '';
              };

              # Repo helper
              sync-dotfiles = {
                body = ''
                  if test -d ~/dev/nix
                    cd ~/dev/nix
                    git pull
                    cd -
                  else
                    git clone git@gitlab.n0de.biz:daniel/nix.git ~/dev/nix
                  end
                '';
              };
              sync-keystore = {
                body = ''
                  gopass sync
                  if test ! $status -eq 0
                    gopass clone git@gitlab.n0de.biz:daniel/keystore.git
                    gopass-jsonapi configure
                  end
                  gopass cat ssh/id_ed25519_sk > ~/.ssh/id_ed25519_sk
                  gopass cat ssh/id_ed25519_sk_backup > ~/.ssh/id_ed25519_sk_backup
                  echo "HCLOUD_TOKEN=\"$(gopass cat secret/tokens/hcloud)\"" > ~/.config/environment.d/20-secrets.conf
                '';
              };
              sync-repos = "sync-dotfiles; sync-keystore";
              upd = "nh os switch -- --refresh --accept-flake-config --no-write-lock-file";
              upd-remote = ''NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild --target-host "ssh-ng://ion@$argv[1]" --use-remote-sudo --impure switch --flake "git+https://gitlab.n0de.biz/daniel/nix?ref=main#$argv[1]" --refresh'';
              upd-build-remote = ''NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild --build-host "ssh-ng://ion@$argv[1]" --use-remote-sudo --impure switch --flake "git+https://gitlab.n0de.biz/daniel/nix?ref=main#$(hostname)" --refresh'';

              # Yubikey helper
              ykcode = "ykman --device 13338635  oath accounts code $argv";

              gitignore = "curl -sL https://www.gitignore.io/api/$argv";
            };
          };
          zsh = {
            enable = true;
            enableCompletion = true;

            plugins = [
              {
                name = "you-should-use";
                src = "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use";
              }
              # {
              #   name = "zsh-autosuggestions";
              #   src = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
              #   file = "zsh-autosuggestions.zsh";
              # }
              # {
              #   name = "zsh-syntax-highlighting";
              #   src = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting";
              #   file = "zsh-syntax-highlighting.zsh";
              # }
            ];
            initContent = # zsh
              ''
                source ~/.zsh/plugins/powerlevel10k-config
                function set-title-precmd() {
                  printf "\e]2;%s\a" "''${PWD/#$HOME/~}"
                }

                function set-title-preexec() {
                  printf "\e]2;%s\a" "$1"
                }
                add-zsh-hook precmd set-title-precmd
                add-zsh-hook preexec set-title-preexec

                function ykreset() {
                  gpg-connect-agent
                  updatestartuptty /bye;
                  killall -9 gpg-agent; sudo systemctl restart pcscd.service
                }

                function sync-dotfiles() {
                  if test -d ~/dev/nix; then
                    cd ~/dev/nix
                    git pull
                    cd -
                  else
                    git clone git@gitlab.n0de.biz:daniel/nix.git ~/dev/nix
                  fi
                }

                function sync-keystore() {
                  gopass
                  sync
                  if test ! $status -eq 0; then
                    gopass clone git@gitlab.n0de.biz:daniel/keystore.git
                    gopass-jsonapi configure
                  fi
                  gopass cat ssh/id_ed25519_sk > ~/.ssh/id_ed25519_sk
                  gopass cat ssh/id_ed25519_sk_backup > ~/.ssh/id_ed25519_sk_backup
                  echo "HCLOUD_TOKEN=\"$(gopass cat secret/tokens/hcloud)\"" > ~/.config/environment.d/20-secrets.conf
                }

                function sync-repos() {
                  sync-dotfiles;
                  sync-keystore;
                }

                function upd() {
                  nh os switch -- --refresh --accept-flake-config --no-write-lock-file
                }

                function gitignore() {
                  curl -sL https://www.gitignore.io/api/$@
                }

                oncall() {
                    source $HOME/dev/sysadmin/scripts/ixo_change_on_call.zsh
                    if [ -z $1 ]; then
                        ixobereitschaft "$HOME/dev/puppet/main" dweissengruber "4368110219130"
                    else
                        ixobereitschaft "$HOME/dev/puppet/main" dweissengruber $@
                    fi
                }

                bindkey "^[[1;5C" forward-word
                bindkey "^[[1;5D" backward-word
              '';
            shellAliases = {
              l = "exa -hF --color=always --icons --sort=created --group-directories-first";
              ls = "exa -lhF --color=always --icons --sort=created --group-directories-first";
              lst = "exa -lahRT --color=always --icons --sort=created --group-directories-first";
              nt = ''vim "+ObsidianWorkspace Private" +ObsidianToday ~/notes/TODO.md'';
              psa = "ps -aweux";

              trip = "sudo trip --tui-theme-colors settings-dialog-bg-color=Black,help-dialog-bg-color=Black";
              yless = "jless --yaml";

              lg = "lazygit";
              ag = "rg";
              ufwlog = ''journalctl -k | grep "IN=.*OUT=.*" | less'';
              sshold = "ssh -c 3des-cbc,aes256-cbc -oKexAlgorithms=+diffie-hellman-group1-sha1 ";
              colour = "grc -es --colour=auto";
              as = "colour as";
              configure = "colour ./configure";
              diff = "colour diff";
              docker = "colour docker";
              gcc = "colour gcc";
              stat = "colour stat";
              head = "colour head";
              ifconfig = "colour ifconfig";
              ld = "colour ld";
              make = "colour make";
              mount = "colour mount";
              netstat = "colour netstat";
              ping = "colour ping";
              ps = "colour ps";
              tcpdump = "sudo grc -es --colour=on tcpdump";
              ss = "colour ss";
              tail = "colour tail";
              traceroute = "colour traceroute";
              kernlog = "sudo journalctl -xe -k -b | less";
              syslog = "sudo journalctl -xef";

              # Git aliases
              gb = "git branch";
              gbc = "git checkout -b";
              gbs = "git show-branch";
              gbS = "git show-branch -a";
              gc = "git commit --verbose";
              gca = "git commit --verbose --all";
              gcm = "g3l -m";
              gcf = "git commit --amend --reuse-message HEAD";
              gcF = "git commit --verbose --amend";
              gcR = ''git reset "HEAD^"'';
              gcs = "git show";
              gdi = ''git status --porcelain --short --ignored | sed -n "s/^!! //p"'';
              gg = "git log --oneline --graph --color --all --decorate";
              gia = "git add";
              giA = "git add --patch";
              giu = "git add --update";
              gid = "git diff --no-ext-diff --cached";
              giD = "git diff --no-ext-diff --cached --word-diff";
              gir = "git reset";
              giR = "git reset --patch";
              gix = "git rm -r --cached";
              giX = "git rm -rf --cached";
              gld = "ydiff -ls -w0 --wrap";
              glc = "git shortlog --summary --numbered";
              gm = "git merge";
              gmc = "git merge --continue";
              gmC = "git merge --no-commit";
              gmF = "git merge --no-ff";
              gma = "git merge --abort";
              gmt = "git mergetool";
              gp = "git push";
              gptst = ''git push -o ci.variable="ALWAYS_RUN_TEST=true"'';
              gpmr = "push -o merge_request.create -o merge_request.target=development";
              gpmrm = "push -o merge_request.create -o merge_request.target=development -o merge_request.merge_when_pipeline_succeeds";
              gpf = "git push --force";
              gpa = "git push --all";
              gpA = "git push --all && git push --tags";
              gpc = ''git push --set-upstream origin "$(git-branch-current 2> /dev/null)"'';
              gpp = ''git pull origin "$(git-branch-current 2> /dev/null)" && git push origin "$(git-branch-current 2> /dev/null)"'';
              gwd = "git diff --no-ext-diff";
              gwD = "git diff --no-ext-diff --word-diff";
              gwr = "git reset --soft";
              gwR = "git reset --hard";
              gwc = "git clean -n";
              gwC = "git clean -f";
              gwx = "git rm -r";
              gwX = "git rm -rf";

              wgup = "wg-quick up ~/.config/wireguard/wg-home.conf";
              wgdown = "wg-quick down ~/.config/wireguard/wg-home.conf";
            };
          };

          starship = {
            enable = true;
            enableZshIntegration = true;
            enableFishIntegration = true;
            settings = {
              add_newline = false;
              command_timeout = 1000;
              time = {
                disabled = true;
              };
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
              # os = {
              #   disabled = false;
              #   format = "$symbol";
              #   style = "";
              # };
              # os.symbols = {
              #   AlmaLinux = "[](fg:text bg:surface1)";
              #   Alpine = "[](fg:blue bg:surface1)";
              #   Amazon = "[](fg:peach bg:surface1)";
              #   Android = "[](fg:green bg:surface1)";
              #   Arch = "[󰣇](fg:sapphire bg:surface1)";
              #   Artix = "[](fg:sapphire bg:surface1)";
              #   CentOS = "[](fg:mauve bg:surface1)";
              #   Debian = "[](fg:red bg:surface1)";
              #   DragonFly = "[](fg:teal bg:surface1)";
              #   EndeavourOS = "[](fg:mauve bg:surface1)";
              #   Fedora = "[](fg:blue bg:surface1)";
              #   FreeBSD = "[](fg:red bg:surface1)";
              #   Garuda = "[](fg:sapphire bg:surface1)";
              #   Gentoo = "[](fg:lavender bg:surface1)";
              #   Illumos = "[](fg:peach bg:surface1)";
              #   Kali = "[](fg:blue bg:surface1)";
              #   Linux = "[](fg:yellow bg:surface1)";
              #   Macos = "[](fg:text bg:surface1)";
              #   Manjaro = "[](fg:green bg:surface1)";
              #   Mariner = "[](fg:sky bg:surface1)";
              #   MidnightBSD = "[](fg:yellow bg:surface1)";
              #   Mint = "[󰣭](fg:teal bg:surface1)";
              #   NetBSD = "[](fg:peach bg:surface1)";
              #   NixOS = "[](fg:sky bg:surface1)";
              #   OpenBSD = "[](fg:yellow bg:surface1)";
              #   openSUSE = "[](fg:green bg:surface1)";
              #   OracleLinux = "[󰌷](fg:red bg:surface1)";
              #   Pop = "[](fg:sapphire bg:surface1)";
              #   Raspbian = "[](fg:maroon bg:surface1)";
              #   Redhat = "[](fg:red bg:surface1)";
              #   RedHatEnterprise = "[](fg:red bg:surface1)";
              #   RockyLinux = "[](fg:green bg:surface1)";
              #   Solus = "[](fg:blue bg:surface1)";
              #   SUSE = "[](fg:green bg:surface1)";
              #   Ubuntu = "[](fg:peach bg:surface1)";
              #   Unknown = "[](fg:text bg:surface1)";
              #   Void = "[](fg:green bg:surface1)";
              #   Windows = "[󰖳](fg:sky bg:surface1)";
              # };
              # username = {
              #   aliases = {
              #     "ion" = "󰝴";
              #     "dweissengruber" = "󰝴";
              #     "root" = "󰱯";
              #   };
              #   format = "[ $user]($style)";
              #   show_always = true;
              #   style_user = "fg:green bg:surface2";
              #   style_root = "fg:red bg:surface2";
              # };
              # hostname = {
              #   disabled = false;
              #   style = "bg:overlay0 fg:red";
              #   ssh_only = false;
              #   ssh_symbol = " 󰖈";
              #   format =
              #     "[ $hostname]($style)[$ssh_symbol](bg:overlay0 fg:maroon)";
              # };
              # directory = {
              #   format = "[ $path]($style)[$read_only]($read_only_style)";
              #   home_symbol = "";
              #   read_only = " 󰈈";
              #   read_only_style = "bold fg:crust bg:mauve";
              #   style = "fg:base bg:mauve";
              #   truncate_to_repo = false;
              #   truncation_length = 3;
              #   truncation_symbol = "…/";
              # };
              # # Shorten long paths by text replacement. Order matters
              # directory.substitutions = {
              #   "Desktop" = "";
              #   "dev" = "";
              #   "notes" = "󰈙";
              #   "Downloads" = "󰉍";
              #   "Music" = "󰎄";
              #   "Pictures" = "";
              #   "Public" = "";
              #   "Vault" = "󰌿";
              #   "tmp" = "󱪃";
              #   "nix" = "󱄅";
              # };
              # # Languages
              # c = {
              #   format = "[ $symbol]($style)";
              #   style = "fg:base bg:peach";
              #   symbol = "";
              # };
              # dotnet = {
              #   format = "[ $symbol]($style)";
              #   style = "fg:base bg:peach";
              #   symbol = "";
              # };
              # golang = {
              #   format = "[ $symbol]($style)";
              #   style = "fg:base bg:peach";
              #   symbol = "";
              # };
              # java = {
              #   format = "[ $symbol]($style)";
              #   style = "fg:base bg:peach";
              #   symbol = "󰬷";
              # };
              # lua = {
              #   format = "[ $symbol]($style)";
              #   style = "fg:base bg:peach";
              #   symbol = "";
              # };
              # nodejs = {
              #   format = "[ $symbol]($style)";
              #   style = "fg:base bg:peach";
              #   symbol = "";
              # };
              # perl = {
              #   format = "[ $symbol]($style)";
              #   style = "fg:base bg:peach";
              #   symbol = "";
              # };
              # php = {
              #   format = "[ $symbol]($style)";
              #   style = "fg:base bg:peach";
              #   symbol = "󰌟";
              # };
              # python = {
              #   format = "[ $symbol]($style)";
              #   style = "fg:base bg:peach";
              #   symbol = "";
              # };
              # ruby = {
              #   format = "[ $symbol]($style)";
              #   style = "fg:base bg:peach";
              #   symbol = "";
              # };
              # rust = {
              #   format = "[ $symbol]($style)";
              #   style = "fg:base bg:peach";
              #   symbol = "";
              # };
              # package = {
              #   format = "[ $version]($style)";
              #   style = "fg:base bg:peach";
              #   version_format = "$raw";
              # };
              # git_branch = {
              #   format = "[ $symbol $branch]($style)";
              #   style = "fg:base bg:peach";
              #   symbol = "";
              # };
              # git_status = {
              #   format = "[ $all_status$ahead_behind]($style)";
              #   style = "fg:base bg:yellow";
              # };
              # # "Shells"
              # container = {
              #   format = "[ $symbol $name]($style)";
              #   style = "fg:base bg:teal";
              # };
              # direnv = {
              #   disabled = false;
              #   format = "[ $loaded]($style)";
              #   allowed_msg = "";
              #   not_allowed_msg = "";
              #   denied_msg = "";
              #   loaded_msg = "󰐍";
              #   unloaded_msg = "󰙧";
              #   style = "fg:base bg:teal";
              #   symbol = "";
              # };
              # nix_shell = {
              #   format = "[ $symbol]($style)";
              #   style = "fg:base bg:teal";
              #   symbol = "󱄅";
              # };
              # cmd_duration = {
              #   format = "[  $duration]($style)";
              #   min_time = 2500;
              #   min_time_to_notify = 60000;
              #   show_notifications = false;
              #   style = "fg:base bg:teal";
              # };
              # jobs = {
              #   format = "[ $symbol $number]($style)";
              #   style = "fg:base bg:teal";
              #   symbol = "󰣖";
              # };
              # shlvl = {
              #   disabled = false;
              #   format = "[ $symbol]($style)";
              #   repeat = false;
              #   style = "fg:surface1 bg:teal";
              #   symbol = "󱆃";
              #   threshold = 3;
              # };
              # status = {
              #   disabled = false;
              #   format = "$symbol";
              #   map_symbol = true;
              #   pipestatus = true;
              #   style = "";
              #   symbol = "[  $status](fg:red bg:pink)";
              #   success_symbol = "";
              #   not_executable_symbol = "[  $common_meaning](fg:red bg:pink)";
              #   not_found_symbol = "[ 󰩌 $common_meaning](fg:red bg:pink)";
              #   sigint_symbol = "[  $signal_name](fg:red bg:pink)";
              #   signal_symbol = "[ ⚡ $signal_name](fg:red bg:pink)";
              # };
              # character = {
              #   disabled = false;
              #   format = "$symbol";
              #   error_symbol = ''

              #     [➜](fg:yellow) '';
              #   success_symbol = ''

              #     [➜](fg:blue) '';
              # };
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
            changeDirWidgetCommand = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
            changeDirWidgetOptions = [ "--preview 'eza --tree --color=always {} | head -200'" ];

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
            extraPackages = with pkgs.bat-extras; [
              batwatch
              prettybat
            ];
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
            nix-direnv = {
              enable = true;
            };
          };
          zoxide = {
            enable = true;
            enableBashIntegration = true;
            enableFishIntegration = true;
            enableZshIntegration = true;
            # Replace cd with z and add cdi to access zi
            options = [ "--cmd cd" ];
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
            signing = {
              signByDefault = true;
            };
            enable = true;
            userName = "${host.username}";
            userEmail = "${host.email}";
            delta = {
              enable = true;
              options = {
                navigate = true;
                side-by-side = true;
              };
            };
            aliases = {
              squash-all = ''!f(){ git reset $(git commit-tree HEAD^{tree} "$@");};f'';
              lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
            };
            extraConfig = {
              push = {
                default = "current";
                autoSetupRemote = true;
              };
              pull = {
                rebase = true;
              };
              init = {
                defaultBranch = "main";
              };
            };
            ignores = [
              "*.log"
              "*.out"
              ".DS_Store"
              "bin/"
              "dist/"
              "result"
            ];
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

        systemd = {
          # Nicely reload system units when changing configs
          user.startServices = "sd-switch";
          user.tmpfiles.rules = [
            "d ${config.home.homeDirectory}/.ssh/sessions 0755 ${host.username} ${host.username} - -"
          ];
        };

        home.stateVersion = "25.05";
      };
    darwin = {
      system.stateVersion = 5;
    };
  };
  defaultTags = {
    defaults = lib.mkDefault true;
  };
}
