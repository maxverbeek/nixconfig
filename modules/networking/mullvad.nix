{ ... }:
{
  flake.modules.nixos.base =
    { ... }:
    {
      services.mullvad-vpn.enable = true;
    };
}
