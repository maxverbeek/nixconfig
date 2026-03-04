{ ... }:
{
  flake.modules.nixos.base =
    { ... }:
    {
      services.tailscale.enable = true;
    };
}
