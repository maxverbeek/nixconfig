{
  nixos.programs.stalker =
    { my, ... }:
    {
      imports = [ my.modules.external.stalker ];

      cachePackages.stalker = my.pkgs.stalker;

      services.stalker.enable = true;
    };
}
