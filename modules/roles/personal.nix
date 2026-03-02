{ config, ... }:
{
  flake.modules.nixos.personal =
    { ... }:
    {
      imports = with config.flake.modules.nixos; [
        _1password
        cachix
        printer
      ];
    };

  flake.modules.homeManager.personal =
    { ... }:
    {
      imports = with config.flake.modules.homeManager; [
        _1password
        gtk
      ];
    };
}
