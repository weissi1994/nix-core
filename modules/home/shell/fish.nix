{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fish
    fishPlugins.fzf
    # fishPlugins.fzf-fish
    fzf
    fishPlugins.grc
    grc
    cava # for cli equealizer #unixporn
    unstable.eza # nice ls
    jless # json less
    sd # modern sed
    choose # modern cut
    gnumake
    yank # Yank terminal output to clipboard.
    seahorse
  ];

  programs = {
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
  };
}
