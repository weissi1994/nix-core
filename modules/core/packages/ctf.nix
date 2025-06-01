{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gdb
    gef
    pwntools
    binutils
    radare2
    (cutter.withPlugins (
      pkgs: with pkgs; [
        cutterPlugins.jsdec
        cutterPlugins.rz-ghidra
        cutterPlugins.sigdb
      ]
    ))
    ghidra
    cht-sh
    # binaryninja-free
  ];
}
