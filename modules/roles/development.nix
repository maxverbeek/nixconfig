{ ... }:
{
  flake.modules.nixos.development = {
    users.users.max.extraGroups = [
      "plugdev"
      "dialout"
      "adbusers"
    ];
  };
}
