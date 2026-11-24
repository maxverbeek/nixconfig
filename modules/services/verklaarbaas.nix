{
  nixos.services.verklaarbaas =
    { my, ... }:
    let
      host = "verklaarbaas.maxverbeek.dev";
    in
    {
      imports = [ my.modules.external.verklaarbaas ];

      # Static site; content is built into /srv/www/verklaarbaas out of band.
      services.caddy.enable = true;
      services.caddy.virtualHosts.${host}.extraConfig = ''
        root * /srv/www/verklaarbaas
        encode zstd gzip
        file_server
      '';

      # The MCP server from the same repo: stateless, on loopback. The module
      # adds /mcp and /mcp/* to the site above and keeps them out of the access log.
      services.verklaarbaas-mcp = {
        enable = true;
        port = 8787;
        caddy.virtualHost = host;
      };

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
    };
}
