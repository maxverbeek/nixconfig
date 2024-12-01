{
  pkgs,
  lib,
  config,
  nvidia,
  ...
}:
{
  # if nvidia patches for hyprland are required, then so is this modesetting thing
  services.xserver.videoDrivers = lib.optionals nvidia [ "nvidia" ];

  # use new kernel for new nvidia drivers
  # boot.kernelPackages = if nvidia then
  #   pkgs.unstable.linuxPackages_latest
  # else
  #   pkgs.linuxPackages_latest;

  hardware.nvidia = lib.optionalAttrs nvidia {
    # open = true;
    modesetting.enable = true;
    powerManagement.enable = false;

    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # my card is too old :(
    open = false;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = lib.optionals nvidia [ pkgs.nvidia-vaapi-driver ];
  };
}
