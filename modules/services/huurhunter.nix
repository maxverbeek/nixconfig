{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      cachePackages.huurhunter = inputs.huurhunter.packages.${system}.default;
    };

  flake.modules.nixos.huurhunter =
    { lib, ... }:
    let
      hostIP = "10.100.0.1";
      webIP = "10.100.0.4"; # web container: behind Caddy, main ingress identity
      monitorIP = "10.100.0.5"; # monitor container primary veth address
      webPort = 3010;

      # Shared SQLite dir on the HOST, bind-mounted RW into both containers.
      # Splitting the two services into separate containers means they can no
      # longer share a StateDirectory inside one namespace, so the DB lives here.
      dbDir = "/var/lib/huurhunter";

      # ── FLOATING IP EGRESS POOL ──────────────────────────────────────────────
      # Each entry gives the monitor one outbound identity: the Go monitor binds
      # source `srcIP`; the host SNATs that source to `fip`. The list is NOT in the
      # repo (these IPs shouldn't be public) — it's generated on the box from
      # `hcloud floating-ip list` by secrets/huurhunter-fips.sh, written to
      # /etc/huurhunter-fips.nix. Empty fallback so the repo builds without it and
      # the pool is simply off until FIPs are provisioned.
      fipsPath = "/etc/huurhunter-fips.nix";
      fips = if builtins.pathExists fipsPath then import fipsPath else [ ];

      secondaryAddrs = map (f: {
        address = f.srcIP;
        prefixLength = 24;
      }) fips;
    in
    {
      # ── DB dir on the host, owned so both containers' huurhunter user can use it.
      # The huurhunter module inside each container runs services as uid/gid for the
      # static `huurhunter` user; the bind-mount exposes this host dir at the same
      # path. 2770 + shared gid keeps the file writable by both. The uid/gid must
      # line up across host and containers — see NOTE below.
      systemd.tmpfiles.rules = [
        "d ${dbDir} 2770 huurhunter huurhunter -"
      ];
      users.users.huurhunter = {
        isSystemUser = true;
        group = "huurhunter";
        uid = 1500; # pinned so the same uid exists in both containers (see NOTE)
      };
      users.groups.huurhunter.gid = 1500;

      # ── WEB CONTAINER: unchanged identity, behind Caddy on the main IP. ─────────
      containers.huurhunter-web = {
        autoStart = true;
        privateNetwork = true;
        hostAddress = hostIP;
        localAddress = webIP;

        bindMounts = {
          "/var/secrets/huurhunter.env" = {
            hostPath = "/var/secrets/huurhunter.env";
            isReadOnly = true;
          };
          "${dbDir}" = {
            hostPath = dbDir;
            isReadOnly = false;
          };
        };

        config = { ... }: {
          imports = [ inputs.huurhunter.nixosModules.web ];
          system.stateVersion = "25.11";
          networking.useHostResolvConf = false;
          networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

          # Pin the shared user's uid/gid to match the host so the bind-mounted DB
          # is owned correctly across the namespace boundary.
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

      # ── MONITOR CONTAINER: egress-only, gets the FIP source addresses. ─────────
      containers.huurhunter-monitor = {
        autoStart = true;
        privateNetwork = true;
        hostAddress = hostIP;
        localAddress = monitorIP;

        bindMounts = {
          "${dbDir}" = {
            hostPath = dbDir;
            isReadOnly = false;
          };
        };

        config = { ... }: {
          imports = [ inputs.huurhunter.nixosModules.monitor ];
          system.stateVersion = "25.11";
          networking.useHostResolvConf = false;
          networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

          users.users.huurhunter.uid = 1500;
          users.groups.huurhunter.gid = 1500;

          # Secondary source IPs the Go monitor binds, one per FIP identity. Added
          # on the container's own veth (eth0) so bind(10.100.0.1z) succeeds.
          networking.interfaces.eth0.ipv4.addresses = secondaryAddrs;

          services.huurhunter.stateDir = dbDir;
          services.huurhunter-monitor = {
            enable = true;
            browser = true;
          };

          # Hand the monitor its egress source-IP pool. The Go monitor binds these
          # per-request (round-robin) as the local source; the host SNATs each to
          # its FIP. Empty pool -> unset -> monitor egresses via the primary IP.
          systemd.services.huurhunter-monitor.environment.HUURHUNTER_EGRESS_IPS =
            lib.mkIf (fips != [ ]) (lib.concatMapStringsSep "," (f: f.srcIP) fips);
        };
      };

      # ── HOST NETWORKING ────────────────────────────────────────────────────────
      # NAT so both containers reach the internet.
      networking.nat = {
        enable = true;
        internalInterfaces = [ "ve-huurhunter-web" "ve-huurhunter-monitor" ];
        externalInterface = "enp1s0";
      };

      # Put each Floating IP on the host NIC (Hetzner Cloud delivers FIPs to the
      # server; they must be configured on the main interface). /32 each.
      networking.interfaces.enp1s0.ipv4.addresses =
        map (f: { address = f.fip; prefixLength = 32; }) fips;

      # Per-FIP SNAT: monitor binds source 10.100.0.1z -> leaves as FIPz.
      # The Go app chooses its identity by which source it binds; the host maps it.
      # Placed in the nat table POSTROUTING via firewall extraCommands.
      networking.firewall.extraCommands = lib.concatMapStrings (f: ''
        iptables -t nat -A POSTROUTING -s ${f.srcIP} -o enp1s0 -j SNAT --to-source ${f.fip}
      '') fips;
      networking.firewall.extraStopCommands = lib.concatMapStrings (f: ''
        iptables -t nat -D POSTROUTING -s ${f.srcIP} -o enp1s0 -j SNAT --to-source ${f.fip} || true
      '') fips;

      # Caddy reverse proxy -> web container only. The FIPs have nothing listening
      # (web is pinned to webIP:webPort, reachable only via this proxy on the main
      # IP), so a target probing a FIP finds a closed port.
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
