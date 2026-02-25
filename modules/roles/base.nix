{ config, ... }:
{
  flake.modules.nixos.base =
    { ... }:
    {
      imports = with config.flake.modules.nixos; [
        locale
        nix-config
        registry
        shell
      ];
    };

  flake.modules.homeManager.base =
    { ... }:
    {
      imports = with config.flake.modules.homeManager; [
        shell
        ssh
        terminal
      ];
    };
}
