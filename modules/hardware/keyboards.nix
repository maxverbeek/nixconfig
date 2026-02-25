{ ... }:
{
  flake.modules.nixos.keyboards =
    { pkgs, ... }:
    {
      services.udev.packages = [
        pkgs.via
        pkgs.qmk-udev-rules
      ];
    };
}
