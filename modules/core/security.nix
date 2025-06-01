{ pkgs, ... }:
{
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

  environment.systemPackages = with pkgs; [
    gnupg
    libfido2
    libu2f-host
    yubikey-personalization
    vulnix
  ];

  services.udev.packages = with pkgs; [
    libu2f-host
    yubikey-personalization
  ];

  # Works around https://github.com/NixOS/nixpkgs/issues/103746
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}
