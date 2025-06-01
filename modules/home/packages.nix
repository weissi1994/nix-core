{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # Fonts
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

      cbonsai # terminal screensaver
      cmatrix
      pipes # terminal screensaver
      sl
      tty-clock # cli clock
    ];
  };
}
