{ inputs, lib, ... }: {
  apps.disko-config = {
    tags = [ "disko" ];
    nixos = { host, lib, ... }:
      let
        defaultFsOpts = [ "compress=zstd" "noatime" ]; # "noexec" ];
        bcachefsRoot = {
          name = "root";
          start = "1G";
          end = "100%";
          content = {
            type = "filesystem";
            format = "bcachefs";
            device = "${host.diskoOsDisk}-part2";
            mountpoint = "/";
          };
        };
        btrfsRootPart = {
          name = "luks";
          start = "1G";
          end = "100%";
          content = {
            type = "luks";
            name = "${host.name}-crypted";
            device = "${host.diskoOsDisk}-part2";
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
                "@" = { };
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
                  mountOptions = [ "compress=zstd" "noatime" ];
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
        diskoOsDisk = {
          type = "disk";
          device = "${host.diskoOsDisk}";
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
                  device = "${host.diskoOsDisk}-part1";
                  mountpoint = "/boot";
                };
              };
              root = if (host.diskoOsLayout == "bcachefs") then
                bcachefsRoot
              else
                btrfsRootPart;
            };
          };
        };
      in {

        imports = [ inputs.disko.nixosModules.disko ];

        boot.initrd.luks.forceLuksSupportInInitrd = true;
        disko.devices = {
          disk = {
            os = diskoOsDisk;
            data_1 = lib.mkIf (host.diskoDataDisks != [ ]) {
              type = "disk";
              device = "${builtins.index host.diskoDataDisks 0}";
              content = {
                type = "gpt";
                partitions = {
                  mdadm = {
                    size = "100%";
                    content = {
                      type = "mdraid";
                      name = "${host.name}";
                    };
                  };
                };
              };
            };
            data_2 = lib.mkIf (host.diskoDataDisks != [ ]) {
              type = "disk";
              device = "${builtins.index host.diskoDataDisks 1}";
              content = {
                type = "gpt";
                partitions = {
                  mdadm = {
                    size = "100%";
                    content = {
                      type = "mdraid";
                      name = "${host.name}";
                    };
                  };
                };
              };
            };
          };
          mdadm = lib.mkIf (host.diskoDataDisks != [ ]) {
            "${host.name}" = {
              type = "mdadm";
              level = 1;
              content = {
                type = "gpt";
                partitions = {
                  primary = {
                    size = "100%";
                    content = {
                      type = "filesystem";
                      format = "ext4";
                      mountpoint = "/";
                    };
                  };
                };
              };
            };
          };
        };
      };
  };
  defaultTags = { disko = lib.mkDefault false; };
}
