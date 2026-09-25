{
  nixos.programs.mictap =
    { my, ... }:
    {
      imports = [ my.modules.external.mictap-recorder ];

      services.mictap.recorder = {
        enable = true;
        server = "http://scopecreep:8765";
      };
    };
}
