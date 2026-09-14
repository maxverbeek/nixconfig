{
  nixos.hardware.keyboards =
    { pkgs, ... }:
    {
      services.udev.packages = [
        pkgs.via
        pkgs.qmk-udev-rules
      ];
    };
}
