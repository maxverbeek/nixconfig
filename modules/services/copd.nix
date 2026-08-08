{
  flake.modules.nixos.copd =
    { inputs, ... }:
    {
      imports = [ inputs.copd.nixosModules.default ];

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
