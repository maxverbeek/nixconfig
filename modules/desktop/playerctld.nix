{ ... }:
{
  flake.modules.nixos.headful = {
    services.playerctld.enable = true;
  };
}
