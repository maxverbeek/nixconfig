{
  nixos.programs.mictap =
    { config, my, ... }:
    {
      imports = [ my.modules.external.mictap-recorder ];

      my.cachePackages.mictap = config.services.mictap.recorder.package;

      services.mictap.recorder = {
        enable = true;
        server = "http://scopecreep:8765";
      };
    };
}
