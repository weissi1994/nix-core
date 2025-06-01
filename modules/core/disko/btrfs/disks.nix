{ lib, config, ... }:
let
  defaultFsOpts = [
    "compress=zstd"
    "noatime"
  ]; # "noexec" ];
in
{
  config = lib.mkIf (config.core.os_layout == "btrfs") {

    boot.initrd.luks.forceLuksSupportInInitrd = true;

    # TODO: convert to systemd unit https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/system/boot/systemd/initrd.nix
    # boot.initrd.postDeviceCommands = lib.mkAfter ''
    #   mkdir /mnt
    #   mount -t btrfs /dev/mapper/enc /mnt
    #   btrfs subvolume delete /mnt/root
    #   btrfs subvolume snapshot /mnt/root-blank /mnt/root
    # '';
    disko.devices = {
      disk = {
        os = {
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
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  device = "${config.core.os_disk}-part1";
                  mountpoint = "/boot";
                };
              };
              # {
              #   name = "swap";
              #   start = "1G";
              #   end = "9G";
              #   part-type = "primary";
              #   content = {
              #     type = "swap";
              #     randomEncryption = true;
              #   };
              # }
              root = {
                name = "luks";
                start = "1G";
                end = "100%";
                content = {
                  type = "luks";
                  name = "${config.core.hostname}-crypted";
                  device = "${config.core.os_disk}-part2";
                  # disable settings.keyFile if you want to use interactive password entry
                  #passwordFile = "/tmp/secret.key"; # Interactive
                  settings = {
                    allowDiscards = true;
                    # keyFile = "/tmp/secret.key";
                  };
                  # additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
                  content = {
                    type = "btrfs";
                    extraArgs = [ "-f" ];
                    subvolumes = {
                      "@" = {
                        # mountOptions = defaultFsOpts;
                      };
                      "@/root" = {
                        mountpoint = "/";
                        mountOptions = defaultFsOpts;
                      };
                      # Mountpoints inferred from subvolume name
                      "@/home" = {
                        mountpoint = "/home";
                        mountOptions = defaultFsOpts;
                      };
                      "@/nix" = {
                        mountpoint = "/nix";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "@/log" = {
                        mountpoint = "/var/log";
                        mountOptions = defaultFsOpts;
                      };
                      "@/swap" = {
                        mountpoint = "/swap";
                        swap.swapfile.size = "32000M";
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
