{ ... }:
{
  flake.modules.nixos.headful =
    { pkgs, ... }:
    {
      networking.networkmanager.enable = true;
      # The NordVPN profile is openvpn-type; without this plugin `nmcli
      # connection up` fails with "VPN service not installed".
      networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
      users.users.max.extraGroups = [ "networkmanager" ];
    };
}
