{
  nixos.services.copd =
    { my, ... }:
    {
      imports = [ my.modules.external.copd ];

      my.cachePackages.copd = my.pkgs.copd;
      my.cachePackages.copd-deps = my.pkgs.copd-deps;

      services.copd = {
        enable = true;
        hostName = "copd.maxverbeek.dev";
      };

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
    };
}
