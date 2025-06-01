{ ... }:
{
  boot = {
    consoleLogLevel = 0;
    initrd.verbose = false;
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "sd_mod"
      "sr_mod"
    ];

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        memtest86.enable = true;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
      timeout = 10;
    };
    supportedFilesystems = [ "ntfs" ];
  };
}
