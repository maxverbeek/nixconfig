{ ... }:
{
  flake.modules.nixos.headful =
    { my, ... }:
    {
      environment.systemPackages = [ my.pkgs.wrapped.wlr-which-key ];
    };
}
