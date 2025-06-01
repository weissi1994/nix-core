{
  config,
  lib,
  username,
  ...
}:
{
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

  services.ssh-agent.enable = true;
  home.file.".face".source = lib.mkDefault ./face.png;
  home = {
    sessionVariables = {
      PAGER = "moar";
      EDITOR = "nvim";
    };
  };
  programs = {
    gpg = {
      enable = true;
      scdaemonSettings = {
        disable-ccid = true;
        pcsc-shared = true;
        disable-application = "piv";
      };
    };
    git = {
      signing = {
        signByDefault = true;
      };
      aliases = {
        squash-all = ''!f(){ git reset $(git commit-tree HEAD^{tree} "$@");};f'';
      };
    };
    lazygit = {
      enable = true;
      settings = {
        gui.theme = {
          lightTheme = false;
        };
      };
    };
  };

  systemd.user.tmpfiles.rules = [
    "d ${config.home.homeDirectory}/.ssh/sessions 0755 ${username} users - -"
  ];
}
