{ config, ... }:
{
  flake.modules.nixos.max = {
    home-manager.users.max =
      { }:
      {
        imports = [ config.flake.modules.homeManager.max ];
      };
  };

  flake.modules.homeManager.max = {
    imports = [ ];

    home.stateVersion = "20.09";
  };
}
