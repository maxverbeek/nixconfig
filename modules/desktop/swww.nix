{ ... }:
{
  flake.modules.homeManager.headful = {
    services.awww.enable = true;
  };
}
