{
  nixos.hardware.nvidia =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        open = false;
      };

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = [ pkgs.nvidia-vaapi-driver ];
      };

      # The driver is unfree-redistributable, so Hydra never caches it: every host
      # otherwise refetches the blob and recompiles the kernel modules against its
      # own kernel. Taken from this host's own evaluated config rather than a bare
      # pkgs, because the module build is kernel-specific.
      cachePackages.nvidia-x11 = config.hardware.nvidia.package;
      cachePackages.nvidia-kernel-modules = builtins.head (
        builtins.filter (
          p: builtins.match ".*nvidia-kernel-modules.*" (p.name or "") != null
        ) config.boot.extraModulePackages
      );
    };
}
