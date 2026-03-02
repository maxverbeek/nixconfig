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
          ConditionPathExists = "!/var/lib/tailscale/hetzner-autoconnect-done";
        };

        path = [
          pkgs.tailscale
          pkgs.curl
        ];

        script = ''
          # Wait for tailscaled to be ready
          sleep 2

          # Hetzner Cloud exposes user-data at this metadata endpoint
          AUTH_KEY=$(curl -sf http://169.254.169.254/hetzner/v1/userdata || true)

          if [ -z "$AUTH_KEY" ]; then
            echo "No user-data found at Hetzner metadata endpoint"
            exit 1
          fi

          echo "Connecting to Tailscale..."
          tailscale up --auth-key="$AUTH_KEY"
          touch /var/lib/tailscale/hetzner-autoconnect-done
        '';
      };
    };
}
