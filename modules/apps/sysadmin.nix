{ inputs, lib, ... }: {
  apps.sysadmin-config = {
    tags = [ "sysadmin" ];
    nixos = { host, pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        asn
        termshark
        dog
        nmap
        trippy
        gping
        ipcalc
        certigo
        dhcpdump
        gdb
        gef
        pwntools
        binutils
        radare2
        (cutter.withPlugins (pkgs:
          with pkgs; [
            cutterPlugins.jsdec
            cutterPlugins.rz-ghidra
            cutterPlugins.sigdb
          ]))
        ghidra
        cht-sh
        # binaryninja-free
      ];
    };
    home = { };
  };
  defaultTags = { sysadmin = lib.mkDefault true; };
}
