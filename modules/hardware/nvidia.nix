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

      # Hydra never caches the unfree-redistributable driver, so pre-build it.
      # Read from this host's own evaluated config, not a bare pkgs: the kernel
      # module build is specific to this host's kernel.
      cachePackages.nvidia-x11 = config.hardware.nvidia.package;
      cachePackages.nvidia-kernel-modules = builtins.head (
        builtins.filter (
          p: builtins.match ".*nvidia-kernel-modules.*" (p.name or "") != null
        ) config.boot.extraModulePackages
      );
    };
}
