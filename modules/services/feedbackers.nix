{
  flake.modules.nixos.feedbackers =
    { pkgs, inputs, ... }:
    let
      containerIP = "10.100.0.2";
      hostIP = "10.100.0.1";
      port = 3001;
    in
    {
      containers.feedbackers = {
        autoStart = true;
        privateNetwork = true;
        hostAddress = hostIP;
        localAddress = containerIP;

        bindMounts = {
          "/var/secrets/feedbackers.env" = {
            hostPath = "/var/secrets/feedbackers.env";
            isReadOnly = true;
          };
        };

        config =
          { pkgs, ... }:
          {
            system.stateVersion = "25.11";

            networking.useHostResolvConf = false;
            networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

            systemd.services.feedbackers = {
              description = "Feedbackers Slack Bot";
              after = [ "network.target" ];
              wantedBy = [ "multi-user.target" ];
              serviceConfig = {
                ExecStart = "${inputs.feedbackers.packages.${pkgs.system}.default}/bin/feedbackers";
                Restart = "always";
                RestartSec = 5;
                EnvironmentFile = "/var/secrets/feedbackers.env";
                Environment = [
                  "PORT=${toString port}"
                  "DATABASE_PATH=/var/lib/feedbackers/feedbackers.db"
                  "HOME=/var/lib/feedbackers"
                ];
                StateDirectory = "feedbackers";
                DynamicUser = true;
              };
            };

            networking.firewall.allowedTCPPorts = [ port ];
          };
      };

      # NAT for container outbound access
      networking.nat = {
        enable = true;
        internalInterfaces = [ "ve-feedbackers" ];
        externalInterface = "enp1s0";
      };

      # Caddy reverse proxy on host
      services.caddy.enable = true;
      services.caddy.virtualHosts."feedbackframework.maxverbeek.dev".extraConfig = ''
        reverse_proxy ${containerIP}:${toString port}
      '';

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
    };
}
