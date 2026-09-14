{
  nixos.services.feedbackers =
    { config, my, ... }:
    let
      containerIP = "10.100.0.2";
      hostIP = "10.100.0.1";
      port = 3001;
    in
    {
      cachePackages.feedbackers = my.pkgs.feedbackers;

      # symlink = false + explicit path: bind-mounted into the container, see
      # the comment in huurhunter.nix
      age.secrets.feedbackers-env = {
        file = ../../secrets/feedbackers.env.age;
        symlink = false;
        path = "/run/container-secrets/feedbackers.env";
      };

      containers.feedbackers = {
        autoStart = true;
        privateNetwork = true;
        hostAddress = hostIP;
        localAddress = containerIP;

        bindMounts = {
          "/var/secrets/feedbackers.env" = {
            hostPath = config.age.secrets.feedbackers-env.path;
            isReadOnly = true;
          };
        };

        config =
          { ... }:
          {
            imports = [ my.modules.external.feedbackers ];

            system.stateVersion = "25.11";

            networking.useHostResolvConf = false;
            networking.nameservers = [
              "1.1.1.1"
              "8.8.8.8"
            ];

            services.feedbackers = {
              enable = true;
              environmentFile = "/var/secrets/feedbackers.env";
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
