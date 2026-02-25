{ ... }:
{
  flake.modules.homeManager.rstudio =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.rstudio ];
    };
}
