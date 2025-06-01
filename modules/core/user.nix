{ pkgs, config, ... }:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.users.${config.core.username} = {
    isNormalUser = true;
    description = "${config.core.username}";
    extraGroups =
      [
        "networkmanager"
        "wheel"
      ]
      ++ ifExists [
        "docker"
        "podman"
        "audio"
        "video"
        "users"
        "input"
      ];
    openssh.authorizedKeys.keys = config.core.ssh_keys;
    shell = pkgs.fish;
  };
  users.users.root = {
    hashedPassword = null;
    openssh.authorizedKeys.keys = config.core.ssh_keys;
  };
  programs.fish.enable = true;
  nix.settings.allowed-users = [ "${config.core.username}" ];
}
