{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cava # for cli equealizer #unixporn
    jless # json less
    sd # modern sed
    choose # modern cut
    gnumake
    yank # Yank terminal output to clipboard.
    # zsh plugins
    tmux
    thefuck
    meslo-lgs-nf
    grc
    fzf
  ];

  programs = {
    nix-index = {
      enable = true;
      enableBashIntegration = false;
      enableZshIntegration = false;
      enableFishIntegration = false;
    };
    command-not-found.enable = true;

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
      initExtra = # zsh
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
  };
}
