{ ... }:
{
  flake.modules.nixos.headful =
    { my, ... }:
    {
      environment.systemPackages = [ my.pkgs.wrapped.rofi ];
    };
}
