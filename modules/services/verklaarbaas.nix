{
  nixos.services.verklaarbaas =
    { ... }:
    {
      # Static site; content is built into /srv/www/verklaarbaas out of band.
      services.caddy.enable = true;
      services.caddy.virtualHosts."verklaarbaas.maxverbeek.dev".extraConfig = ''
        root * /srv/www/verklaarbaas
        encode zstd gzip
        file_server
      '';

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
    };
}
