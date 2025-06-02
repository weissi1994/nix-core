{ inputs, lib, config, ... }: {
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {
      username = config.core.username;
      hostname = config.core.hostname;
      desktop = config.core.desktop;
      stateVersion = config.core.stateVersion;
      inputs = inputs;
    };
    users.${config.core.username} = {
      imports = [
        ../home
        inputs.nixvim.homeManagerModules.nixvim
        # inputs.stylix.homeManagerModules.stylix
      ] ++ lib.optional (config.core.desktop != null) ../home/desktop.nix;
      home = {
        username = "${config.core.username}";
        homeDirectory = "/home/${config.core.username}";
        stateVersion = "${config.core.stateVersion}";
      };
      programs.home-manager.enable = true;
    };
    backupFileExtension = "bak";
  };
}
