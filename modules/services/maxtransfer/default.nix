{
  nixos.services.maxtransfer =
    { pkgs, ... }:
    {
      services.caddy.enable = true;
      services.caddy.virtualHosts."maxtransfer.online".extraConfig = ''
        root * ${pkgs.linkFarm "maxtransfer" { "image.png" = ./image.png; }}
        rewrite * /image.png
        file_server
      '';

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
    };
}
