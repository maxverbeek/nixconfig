{ ... }:
{
  flake.modules.nixos.headful =
    { ... }:
    {
      users.users.max.extraGroups = [ "video" ];
    };
}
