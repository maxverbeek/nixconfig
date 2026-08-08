{ ... }:
{
  # NixOS module that reads a Tailscale auth key from Hetzner Cloud
  # user-data and automatically joins the tailnet on first boot.
  #
  # User-data should be the raw auth key string (tskey-auth-...).
  flake.modules.nixos.hetzner-tailscale-cloudinit =
    { pkgs, ... }:
    {
      systemd.services.tailscale-autoconnect = {
        description = "Automatically connect to Tailscale using Hetzner user-data";

        after = [
          "tailscaled.service"
          "network-online.target"
        ];
        wants = [
          "tailscaled.service"
          "network-online.target"
        ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };

        path = [
          pkgs.tailscale
          pkgs.curl
          pkgs.jq
        ];

        script = ''
          # Let tailscaled settle; it is up but the backend may still be starting.
          for _ in $(seq 10); do
            STATE=$(tailscale status --json 2>/dev/null | jq -r .BackendState)
            [ "$STATE" = "NoState" ] || [ -z "$STATE" ] || break
            sleep 1
          done

          # Already on the tailnet (manual join, or a previous boot) — nothing to do.
          if [ "$STATE" = "Running" ]; then
            echo "Tailscale already connected; nothing to do"
            exit 0
          fi

          # Hetzner Cloud exposes user-data at this metadata endpoint
          AUTH_KEY=$(curl -sf http://169.254.169.254/hetzner/v1/userdata || true)

          if [ -z "$AUTH_KEY" ]; then
            echo "Not connected and no user-data at Hetzner metadata endpoint"
            exit 1
          fi

          echo "Connecting to Tailscale..."
          tailscale up --auth-key="$AUTH_KEY"
        '';
      };
    };
}
