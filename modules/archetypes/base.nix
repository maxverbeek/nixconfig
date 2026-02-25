{ config, ... }:
{
  flake.modules.nixos.base =
    { ... }:
    {
      imports = with config.flake.modules.nixos; [
        _1password
        bluetooth
        cachix
        docker
        fonts
        nix-config
        pipewire
        printer
        registry
        shell
      ];
    };

  flake.modules.homeManager.base =
    { ... }:
    {
      imports = with config.flake.modules.homeManager; [
        gtk
        shell
        ssh
        terminal
      ];
    };
}
