{ config, ... }:
{
  flake.modules.nixos.multimedia =
    { ... }:
    {
      imports = with config.flake.modules.nixos; [
        bluetooth
        pipewire
      ];
    };
}
