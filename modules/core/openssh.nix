{ lib, ... }: {
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
}
