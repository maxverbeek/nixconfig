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
        extraOptions = [ "--network=host" ];
      };

      # networking.firewall.allowedTCPPorts = [ 5678 ];
    };
}
