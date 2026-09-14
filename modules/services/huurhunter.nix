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
      nordlynxModule = my.modules.nixos.network.nordlynx;

      hostIP = "10.100.0.1";
      webIP = "10.100.0.4";
      monitorIP = "10.100.0.5";
      webPort = 3010;

      # Shared SQLite dir on the HOST, bind-mounted RW into both containers:
      # split across two containers they can no longer share a StateDirectory.
      dbDir = "/var/lib/huurhunter";

      # The FIP list lives in the PRIVATE huurhunter repo (`egressFips` flake
      # output), not here: nixconfig is public. Empty list -> plain NAT on the
      # main IP until a FIP is provisioned.
      fips = my.meta.huurhunter.egressFips;
      egressFip = if fips == [ ] then null else builtins.head fips;
    in
    {
      cachePackages.huurhunter = my.pkgs.huurhunter;

      # symlink = false: bind-mounted into nspawn containers, and a /run/agenix
      # symlink would dangle across agenix generations inside the mount; a plain
      # file is mounted by inode and stays valid. The explicit path is then
      # required — the default /run/agenix/<name> would become a real directory
      # and break the generation symlink agenix places there.
      age.secrets.huurhunter-env = {
        file = ../../secrets/huurhunter.env.age;
        symlink = false;
        path = "/run/container-secrets/huurhunter.env";
      };
      age.secrets.huurhunter-monitor-env = {
        file = ../../secrets/huurhunter-monitor.env.age;
        symlink = false;
        path = "/run/container-secrets/huurhunter-monitor.env";
      };
      age.secrets.nordlynx-key = {
        file = ../../secrets/nordlynx.key.age;
        symlink = false;
        path = "/run/container-secrets/nordlynx.key";
      };
      # The monitor container brings up a WireGuard interface; it cannot modprobe.
      boot.kernelModules = [ "wireguard" ];

      # 2770 + a shared gid keeps the DB writable by both containers. The uid/gid
      # must be pinned identically on the host and in both containers, or the
      # bind-mounted DB is owned by the wrong user across the namespace boundary.
      systemd.tmpfiles.rules = [
        "d ${dbDir} 2770 huurhunter huurhunter -"
      ];
      users.users.huurhunter = {
        isSystemUser = true;
        group = "huurhunter";
        uid = 1500;
      };
      users.groups.huurhunter.gid = 1500;

      # Web container: behind Caddy on the main IP.
      containers.hh-web = {
        autoStart = true;
        privateNetwork = true;
        hostAddress = hostIP;
        localAddress = webIP;

        bindMounts = {
          "/var/secrets/huurhunter.env" = {
            hostPath = config.age.secrets.huurhunter-env.path;
            isReadOnly = true;
          };
          "${dbDir}" = {
            hostPath = dbDir;
            isReadOnly = false;
          };
        };

        config = { ... }: {
          imports = [ my.modules.external.huurhunter-web ];
          system.stateVersion = "25.11";
          networking.useHostResolvConf = false;
          networking.nameservers = [
            "1.1.1.1"
            "8.8.8.8"
          ];

          users.users.huurhunter.uid = 1500;
          users.groups.huurhunter.gid = 1500;

          services.huurhunter.stateDir = dbDir;
          services.huurhunter-web = {
            enable = true;
            address = "0.0.0.0:${toString webPort}";
            baseUrl = "https://huur.maxverbeek.dev";
            environmentFile = "/var/secrets/huurhunter.env";
          };

          networking.firewall.allowedTCPPorts = [ webPort ];
        };
      };

      # Monitor container: egress-only, SNATed to the FIP below.
      containers.hh-mon = {
        autoStart = true;
        privateNetwork = true;
        hostAddress = hostIP;
        localAddress = monitorIP;

        bindMounts = {
          "/var/secrets/huurhunter-monitor.env" = {
            hostPath = config.age.secrets.huurhunter-monitor-env.path;
            isReadOnly = true;
          };
          "/var/secrets/nordlynx.key" = {
            hostPath = config.age.secrets.nordlynx-key.path;
            isReadOnly = true;
          };
          "${dbDir}" = {
            hostPath = dbDir;
            isReadOnly = false;
          };
        };

        config = { ... }: {
          imports = [
            my.modules.external.huurhunter-monitor
            nordlynxModule
          ];
          system.stateVersion = "25.11";
          networking.useHostResolvConf = false;
          networking.nameservers = [
            "1.1.1.1"
            "8.8.8.8"
          ];

          users.users.huurhunter.uid = 1500;
          users.groups.huurhunter.gid = 1500;

          services.huurhunter.stateDir = dbDir;
          services.huurhunter-monitor = {
            enable = true;
            browser = true;
            impersonate = true;
            environmentFile = "/var/secrets/huurhunter-monitor.env";
          };

          # Cloudflare serves the whole Hetzner ASN a managed challenge on some
          # sources; a commercial VPN exit passes clean. Only the curl-impersonate
          # lane is bound to the tunnel address, so Chromium, the Go lane and DNS
          # keep leaving via the FIP.
          services.nordlynx = {
            enable = true;
            mode = "bind";
            privateKeyFile = "/var/secrets/nordlynx.key";
          };
          systemd.services.huurhunter-monitor = {
            after = [ "wg-quick-nordlynx.service" ];
            environment.CURL_IMPERSONATE_BIND = "10.5.0.2";
          };
        };
      };

      networking.nat = {
        enable = true;
        internalInterfaces = [
          "ve-hh-web"
          "ve-hh-mon"
        ];
        externalInterface = "enp1s0";
      };

      # Add the Floating IP as a SECONDARY alias, never via
      # networking.interfaces.*.ipv4.addresses: the primary IP comes over DHCP,
      # and declaring an address there switches the interface to static and drops
      # the lease — it took the whole box off the network once. This oneshot is
      # purely additive. The FIP must be on the NIC for conntrack to accept the
      # SNAT reply packets.
      systemd.services.huurhunter-fip-addr = lib.mkIf (egressFip != null) {
        description = "Add huurhunter Floating IP as secondary address on enp1s0";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.iproute2}/bin/ip addr replace ${egressFip}/32 dev enp1s0";
          ExecStop = "${pkgs.iproute2}/bin/ip addr del ${egressFip}/32 dev enp1s0";
        };
      };

      # SNAT the whole monitor container to the FIP, matched before the generic
      # MASQUERADE from networking.nat so it wins. Covers every protocol, so the
      # headless-Chromium path is included without app cooperation.
      networking.firewall.extraCommands = lib.optionalString (egressFip != null) ''
        # purge SNAT rules for the monitor IP from PREVIOUS generations first:
        # a rotated FIP otherwise leaves a stale rule that wins on first-match
        # and blackholes the container (its old FIP no longer routes)
        iptables -t nat -S POSTROUTING | grep -- "-s ${monitorIP}/32 -o enp1s0 -j SNAT" \
          | sed 's/^-A/-D/' | while read -r rule; do iptables -t nat $rule; done
        iptables -t nat -A POSTROUTING -s ${monitorIP} -o enp1s0 -j SNAT --to-source ${egressFip}
      '';
      networking.firewall.extraStopCommands = lib.optionalString (egressFip != null) ''
        iptables -t nat -D POSTROUTING -s ${monitorIP} -o enp1s0 -j SNAT --to-source ${egressFip} || true
      '';

      # Web container only: nothing listens on the FIPs, so a target probing one
      # finds a closed port.
      services.caddy.enable = true;
      services.caddy.virtualHosts."huur.maxverbeek.dev".extraConfig = ''
        reverse_proxy ${webIP}:${toString webPort}
      '';

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
    };
}
