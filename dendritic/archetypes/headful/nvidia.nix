{ ... }:
{
  # NixOS: nvidia driver config — keeps its own name (conditional on specialArgs.nvidia)
  flake.modules.nixos.nvidia =
    {
      pkgs,
      lib,
      config,
      nvidia,
      ...
    }:
    {
      services.xserver.videoDrivers = lib.optionals nvidia [ "nvidia" ];

      hardware.nvidia = lib.optionalAttrs nvidia {
        modesetting.enable = true;
        powerManagement.enable = false;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        open = false;
      };

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = lib.optionals nvidia [ pkgs.nvidia-vaapi-driver ];
      };
    };
}
