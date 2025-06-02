{ config, lib, pkgs, ... }: {
  home = {
    packages = with pkgs; [
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
    ];
    sessionVariables = {
      EDITOR = "nvim";
      SYSTEMD_EDITOR = "nvim";
      VISUAL = "nvim";
      NH_FLAKE = "git+https://gitlab.n0de.biz/daniel/nix?ref=main";
    };
  };

  programs = {
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
          format = "[ $hostname]($style)[$ssh_symbol](bg:overlay0 fg:maroon)";
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
        top = "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
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
    gpg.enable = true;
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

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = lib.mkDefault true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Screenshots";
      };
    };
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Source Serif" "Noto Color Emoji" ];
      sansSerif = [ "Work Sans" "Fira Sans" "Noto Color Emoji" ];
      monospace = [
        "FiraCode Nerd Font Mono"
        "Font Awesome 6 Free"
        "Font Awesome 6 Brands"
        "Symbola"
        "Noto Emoji"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
