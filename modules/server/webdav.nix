{
  flake.modules.nixos.webdav =
    { pkgs, ... }:
    let
      port = 8543;
      htpasswdFile = "/run/secrets/webdav.htpasswd";
      serveDirectory = "/srv/data/webdav";
    in
    {
      systemd.tmpfiles.rules = [
        "d ${serveDirectory} 0750 webdav webdav -"
      ];

      users.users.webdav = {
        isSystemUser = true;
        group = "webdav";
        home = serveDirectory;
      };

      users.groups.webdav = { };

      services.caddy.enable = true;
      services.caddy.virtualHosts."webdav.maxverbeek.dev".extraConfig = ''
        reverse_proxy localhost:${toString port}
      '';

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      services.fail2ban.jails.caddy-webdav = {
        enabled = true;
        settings = {
          filter = "caddy-status-401-403-500";
          logpath = "/var/log/caddy/access-webdav.maxverbeek.dev.log";
          backend = "auto";
          maxretry = 5;
        };
      };

      systemd.services.webdav = {
        description = "Rclone WebDAV server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.rclone}/bin/rclone serve webdav --addr :${toString port} --htpasswd ${htpasswdFile} ${serveDirectory}";
          Restart = "always";
          User = "webdav";
          Group = "webdav";
        };
      };
    };
}
