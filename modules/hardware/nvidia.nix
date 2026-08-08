{ config, ... }:
{
  # The driver is unfree-redistributable, so Hydra never caches it: every host
  # otherwise refetches the blob and recompiles the kernel modules against its
  # own kernel. Taken from desknix's evaluated config rather than a bare pkgs,
  # because the module build is kernel-specific — thinkpad shares the kernel,
  # so one entry covers both.
  perSystem = {
    cachePackages =
      let
        nvidia = config.flake.nixosConfigurations.desknix.config;
      in
      {
        nvidia-x11 = nvidia.hardware.nvidia.package;
        nvidia-kernel-modules = builtins.head (
          builtins.filter (
            p: builtins.match ".*nvidia-kernel-modules.*" (p.name or "") != null
          ) nvidia.boot.extraModulePackages
        );
      };
  };

  # NixOS: nvidia driver config — keeps its own name (conditional on specialArgs.nvidia)
  flake.modules.nixos.nvidia =
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
    };
}
