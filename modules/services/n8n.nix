{ ... }:
{
  flake.modules.nixos.n8n =
    { ... }:
    {
      virtualisation.oci-containers.backend = "podman";

      virtualisation.oci-containers.containers.n8n = {
        image = "n8nio/n8n:latest";
        volumes = [ "n8n-data:/home/node/.n8n" ];
        environment = {
          N8N_DIAGNOSTICS_ENABLED = "false";
          N8N_SECURE_COOKIE = "false";
        };
        ports = [ "127.0.0.1:5678:5678" ];
      };

      services.caddy.enable = true;
      services.caddy.virtualHosts."n8n.maxverbeek.dev".extraConfig = ''
        reverse_proxy localhost:5678
      '';

      services.fail2ban.jails.caddy-n8n = {
        enabled = true;
        settings = {
          filter = "caddy-status-401-403-500";
          logpath = "/var/log/caddy/access-n8n.maxverbeek.dev.log";
          backend = "auto";
          maxretry = 5;
        };
      };

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
    };
}
