{ ... }:
{
  flake.modules.homeManager.development =
    { config, ... }:
    {
      programs.go = {
        enable = true;
        env = {
          GOPATH = "${config.home.homeDirectory}/go";
          GOBIN = "${config.home.homeDirectory}/go/bin";
        };
      };
    };
}
