{ ... }:
{
  flake.modules.nixos.headful = {
    networking.networkmanager.enable = true;
    users.users.max.extraGroups = [ "networkmanager" ];
  };
}
