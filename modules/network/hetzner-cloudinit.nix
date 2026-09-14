{
  # Joins the tailnet on first boot from a Hetzner Cloud user-data auth key
  # (user-data is the raw tskey-auth-... string).
  nixos.network.hetzner-cloudinit =
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

        # First boot only: the auth key is single-use, so a re-run can only
        # fail. Must live in unitConfig — ConditionPathExists is a [Unit]
        # directive and is silently ignored in serviceConfig.
        unitConfig.ConditionPathExists = "!/var/lib/tailscale/hetzner-autoconnect-done";

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
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
