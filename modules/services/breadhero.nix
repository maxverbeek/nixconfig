{
  flake.modules.nixos.breadhero =
    { inputs, ... }:
    let
      containerIP = "10.100.0.3";
      hostIP = "10.100.0.1";
      port = 3002;
    in
    {
      containers.breadhero = {
        autoStart = true;
        privateNetwork = true;
        hostAddress = hostIP;
        localAddress = containerIP;

        bindMounts = {
          "/var/secrets/breadhero-slack-bot-token" = {
            hostPath = "/var/secrets/breadhero-slack-bot-token";
            isReadOnly = true;
          };
          "/var/secrets/breadhero-slack-signing-secret" = {
            hostPath = "/var/secrets/breadhero-slack-signing-secret";
            isReadOnly = true;
          };
          "/var/secrets/breadhero-leaderboard-api-key" = {
            hostPath = "/var/secrets/breadhero-leaderboard-api-key";
            isReadOnly = true;
          };
        };

        config =
          { ... }:
          {
            imports = [ inputs.breadhero.nixosModules.default ];

            system.stateVersion = "25.11";

            networking.useHostResolvConf = false;
            networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

            services.breadhero = {
              enable = true;
              slackBotTokenFile = "/var/secrets/breadhero-slack-bot-token";
              slackSigningSecretFile = "/var/secrets/breadhero-slack-signing-secret";
              leaderboardApiKeyFile = "/var/secrets/breadhero-leaderboard-api-key";
              port = port;
            };

            networking.firewall.allowedTCPPorts = [ port ];
          };
      };

      # NAT for container outbound access
      networking.nat = {
        enable = true;
        internalInterfaces = [ "ve-breadhero" ];
        externalInterface = "enp1s0";
      };

      # Caddy reverse proxy on host
      services.caddy.enable = true;
      services.caddy.virtualHosts."breadhero.maxverbeek.dev".extraConfig = ''
        reverse_proxy ${containerIP}:${toString port}
      '';

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
    };
}
