{ ... }:
{
  flake.modules.nixos.clamav = {
    services.clamav.daemon.enable = true;
  };
}
