{ ... }:
{
  flake.modules.homeManager.playerctld =
    { pkgs, ... }:
    {
      services.playerctld.enable = true;
      home.packages = [ pkgs.playerctl ];
    };
}
