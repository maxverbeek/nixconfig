{ ... }:
{
  flake.modules.homeManager.headful = {
    services.swww.enable = true;
  };
}
