# Provides reasonable defaults to get started... mainly
# stuff to ensure your system can reliably rebuild this flake
# in the future.

{ inputs, lib, ... }: {
  apps.nvidia-config = {
    tags = [ "nvidia" ];
    nixos = { host, pkgs, config, ... }: {
      hardware = {
        graphics = {
          extraPackages = with pkgs; [
            vulkan-validation-layers
            libvdpau-va-gl
          ];
        };
        nvidia = {
          prime.offload.enable = false;

          # Modesetting is required.
          modesetting.enable = true;

          # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
          powerManagement.enable = false;
          # Fine-grained power management. Turns off GPU when not in use.
          # Experimental and only works on modern Nvidia GPUs (Turing or newer).
          powerManagement.finegrained = false;

          # Use the NVidia open source kernel module (not to be confused with the
          # independent third-party "nouveau" open source driver).
          # Support is limited to the Turing and later architectures. Full list of
          # supported GPUs is at:
          # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
          # Only available from driver 515.43.04+
          # Currently alpha-quality/buggy, so false is currently the recommended setting.
          open = true;

          # Enable the Nvidia settings menu,
          # accessible via `nvidia-settings`.
          nvidiaSettings = true;
          nvidiaPersistenced = false;

          # Optionally, you may need to select the appropriate driver version for your specific GPU.
          package = config.boot.kernelPackages.nvidiaPackages.beta;
        };

      };

      environment.systemPackages = with pkgs; [ nvitop ];
      services.xserver.videoDrivers = [ "nvidia" "nouveau" ];
      programs.sway.extraOptions = [ "--unsupported-gpu" ];
    };
    home = { };
  };
  defaultTags = { nvidia = lib.mkDefault false; };
}
