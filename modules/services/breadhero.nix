{
  nixos.services.breadhero =
    { config, my, ... }:
    let
      containerIP = "10.100.0.3";
      hostIP = "10.100.0.1";
      port = 3002;
    in
    {
      cachePackages.breadhero = my.pkgs.breadhero;

      # symlink = false + explicit path: bind-mounted into the container, see
      # the comment in huurhunter.nix
      age.secrets = {
        breadhero-slack-bot-token = {
          file = ../../secrets/breadhero-slack-bot-token.age;
          symlink = false;
          path = "/run/container-secrets/breadhero-slack-bot-token";
        };
        breadhero-slack-signing-secret = {
          file = ../../secrets/breadhero-slack-signing-secret.age;
          symlink = false;
          path = "/run/container-secrets/breadhero-slack-signing-secret";
        };
        breadhero-leaderboard-api-key = {
          file = ../../secrets/breadhero-leaderboard-api-key.age;
          symlink = false;
          path = "/run/container-secrets/breadhero-leaderboard-api-key";
        };
      };

      containers.breadhero = {
        autoStart = true;
        privateNetwork = true;
        hostAddress = hostIP;
        localAddress = containerIP;

        bindMounts = {
          "/var/secrets/breadhero-slack-bot-token" = {
            hostPath = config.age.secrets.breadhero-slack-bot-token.path;
            isReadOnly = true;
          };
          "/var/secrets/breadhero-slack-signing-secret" = {
            hostPath = config.age.secrets.breadhero-slack-signing-secret.path;
            isReadOnly = true;
          };
          "/var/secrets/breadhero-leaderboard-api-key" = {
            hostPath = config.age.secrets.breadhero-leaderboard-api-key.path;
            isReadOnly = true;
          };
        };

        config =
          { ... }:
          {
            imports = [ my.modules.external.breadhero ];

            system.stateVersion = "25.11";

            networking.useHostResolvConf = false;
            networking.nameservers = [
              "1.1.1.1"
              "8.8.8.8"
            ];

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

      networking.nat = {
        enable = true;
        internalInterfaces = [ "ve-breadhero" ];
        externalInterface = "enp1s0";
      };

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
