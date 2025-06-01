{ config, lib, ... }:
{
  config = lib.mkIf (config.core.data_disks != [ ]) {
    disko.devices = {
      disk = {
        data_1 = {
          type = "disk";
          device = "${builtins.index config.core.data_disks 0}";
          content = {
            type = "gpt";
            partitions = {
              mdadm = {
                size = "100%";
                content = {
                  type = "mdraid";
                  name = "${config.core.hostname}";
                };
              };
            };
          };
        };
        data_2 = {
          type = "disk";
          device = "${builtins.index config.core.data_disks 1}";
          content = {
            type = "gpt";
            partitions = {
              mdadm = {
                size = "100%";
                content = {
                  type = "mdraid";
                  name = "${config.core.hostname}";
                };
              };
            };
          };
        };
      };
      mdadm = {
        "${config.core.hostname}" = {
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
}
