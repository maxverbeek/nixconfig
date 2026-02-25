{ ... }:
{
  flake.modules.nixos.networkmanager = {
    networking.networkmanager.enable = true;
    users.users.max.extraGroups = [ "networkmanager" ];
  };
}
