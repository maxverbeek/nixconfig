{ ... }:
{
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
