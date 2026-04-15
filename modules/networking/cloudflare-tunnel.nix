{ ... }:
{
  flake.modules.nixos.base =
    { ... }:
    {
      services.cloudflared.enable = true;
    };
}
