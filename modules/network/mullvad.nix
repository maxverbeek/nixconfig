{
  nixos.network.mullvad =
    { ... }:
    {
      services.mullvad-vpn.enable = true;
    };
}
