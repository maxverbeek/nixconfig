{ ... }:
{
  flake.modules.homeManager.headful =
    { pkgs, ... }:
    {
      services.playerctld.enable = true;
      home.packages = [ pkgs.playerctl ];
    };
}
