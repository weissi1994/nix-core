{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf (config.core.os_layout == "bcachefs") {

    boot.supportedFilesystems = lib.mkForce [
      "btrfs"
      "bcachefs"
      "cifs"
      "f2fs"
      "jfs"
      "ntfs"
      "reiserfs"
      "vfat"
      "xfs"
    ];
    boot.kernelPackages = pkgs.linuxPackages_testing;

    # TODO: convert to systemd unit https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/system/boot/systemd/initrd.nix
    # boot.initrd.postDeviceCommands = lib.mkAfter ''
    #   mkdir /mnt
    #   mount -t btrfs /dev/mapper/enc /mnt
    #   btrfs subvolume delete /mnt/root
    #   btrfs subvolume snapshot /mnt/root-blank /mnt/root
    # '';
    disko.devices = {
      disk = {
        disk1 = {
          type = "disk";
          device = "${config.core.os_disk}";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                name = "ESP";
                label = "ESP";
                start = "1MiB";
                end = "1G";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  device = "${config.core.os_disk}-part1";
                  mountpoint = "/boot";
                };
              };
              root = {
                name = "root";
                start = "1G";
                end = "100%";
                content = {
                  type = "filesystem";
                  format = "bcachefs";
                  device = "${config.core.os_disk}-part2";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}
