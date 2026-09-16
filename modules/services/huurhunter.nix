{
  nixos.services.huurhunter =
    {
      config,
      lib,
      pkgs,
      my,
      ...
    }:
    let
      webPort = 3010;
      monitorIP = config.containers.hh-mon.localAddress;
      ext = config.networking.nat.externalInterface;

      # Shared SQLite dir on the HOST, bind-mounted RW into both guests: split
      # across two guests they can no longer share a StateDirectory.
      dbDir = "/var/lib/huurhunter";

      # 2770 + a shared gid keeps the DB writable by both guests. The uid/gid
      # must be pinned identically on the host and in both guests, or the
      # bind-mounted DB is owned by the wrong user across the namespace boundary.
      users = {
        users.huurhunter = {
          isSystemUser = true;
          group = "huurhunter";
          uid = 1500;
        };
        groups.huurhunter.gid = 1500;
      };

      # The FIP list lives in the PRIVATE huurhunter repo (`egressFips` flake
      # output), not here: nixconfig is public. Empty list -> plain NAT on the
      # main IP until a FIP is provisioned.
      fips = my.meta.huurhunter.egressFips;
      egressFip = if fips == [ ] then null else builtins.head fips;
    in
    {
      imports = [ my.modules.nixos.system.guests ];

      cachePackages.huurhunter = my.pkgs.huurhunter;

      # The monitor guest brings up a WireGuard interface; it cannot modprobe.
      boot.kernelModules = [ "wireguard" ];

      systemd.tmpfiles.rules = [
        "d ${dbDir} 2770 huurhunter huurhunter -"
      ];
      inherit users;

      # Web guest: behind Caddy on the main IP. Nothing listens on the FIPs, so
      # a target probing one finds a closed port.
      guests.hh-web = {
        ip = 4;
        secrets.env = my.secrets.huurhunter-env.file;
        proxy."huur.maxverbeek.dev" = webPort;
        modules = [ my.modules.external.huurhunter-web ];
        config =
          { secrets, ... }:
          {
            inherit users;
            services.huurhunter.stateDir = dbDir;
            services.huurhunter-web = {
              enable = true;
              address = "0.0.0.0:${toString webPort}";
              baseUrl = "https://huur.maxverbeek.dev";
              environmentFile = secrets.env;
            };
          };
      };
      containers.hh-web.bindMounts.${dbDir} = {
        hostPath = dbDir;
        isReadOnly = false;
      };

      # Monitor guest: egress-only, SNATed to the FIP below.
      guests.hh-mon = {
        ip = 5;
        secrets = {
          env = my.secrets.huurhunter-monitor-env.file;
          nordlynx-key = my.secrets.nordlynx-key.file;
        };
        modules = [
          my.modules.external.huurhunter-monitor
          my.modules.nixos.network.nordlynx
        ];
        config =
          { secrets, ... }:
          {
            inherit users;
            services.huurhunter.stateDir = dbDir;
            services.huurhunter-monitor = {
              enable = true;
              browser = true;
              impersonate = true;
              environmentFile = secrets.env;
            };

            # Cloudflare serves the whole Hetzner ASN a managed challenge on some
            # sources; a commercial VPN exit passes clean. Only the curl-impersonate
            # lane is bound to the tunnel address, so Chromium, the Go lane and DNS
            # keep leaving via the FIP.
            services.nordlynx = {
              enable = true;
              mode = "bind";
              privateKeyFile = secrets.nordlynx-key;
            };
            systemd.services.huurhunter-monitor = {
              after = [ "wg-quick-nordlynx.service" ];
              environment.CURL_IMPERSONATE_BIND = "10.5.0.2";
            };
          };
      };
      containers.hh-mon.bindMounts.${dbDir} = {
        hostPath = dbDir;
        isReadOnly = false;
      };

      # Add the Floating IP as a SECONDARY alias, never via
      # networking.interfaces.*.ipv4.addresses: the primary IP comes over DHCP,
      # and declaring an address there switches the interface to static and drops
      # the lease; it took the whole box off the network once. This oneshot is
      # purely additive. The FIP must be on the NIC for conntrack to accept the
      # SNAT reply packets.
      systemd.services.huurhunter-fip-addr = lib.mkIf (egressFip != null) {
        description = "Add huurhunter Floating IP as secondary address on ${ext}";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.iproute2}/bin/ip addr replace ${egressFip}/32 dev ${ext}";
          ExecStop = "${pkgs.iproute2}/bin/ip addr del ${egressFip}/32 dev ${ext}";
        };
      };

      # SNAT the whole monitor guest to the FIP, matched before the generic
      # MASQUERADE from networking.nat so it wins. Covers every protocol, so the
      # headless-Chromium path is included without app cooperation.
      networking.firewall.extraCommands = lib.optionalString (egressFip != null) ''
        # purge SNAT rules for the monitor IP from PREVIOUS generations first:
        # a rotated FIP otherwise leaves a stale rule that wins on first-match
        # and blackholes the guest (its old FIP no longer routes)
        iptables -t nat -S POSTROUTING | grep -- "-s ${monitorIP}/32 -o ${ext} -j SNAT" \
          | sed 's/^-A/-D/' | while read -r rule; do iptables -t nat $rule; done
        iptables -t nat -A POSTROUTING -s ${monitorIP} -o ${ext} -j SNAT --to-source ${egressFip}
      '';
      networking.firewall.extraStopCommands = lib.optionalString (egressFip != null) ''
        iptables -t nat -D POSTROUTING -s ${monitorIP} -o ${ext} -j SNAT --to-source ${egressFip} || true
      '';
    };
}
