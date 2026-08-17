{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      cachePackages.huurhunter = inputs.huurhunter.packages.${system}.default;
    };

  flake.modules.nixos.huurhunter =
    { lib, inputs, ... }:
    let
      hostIP = "10.100.0.1";
      webIP = "10.100.0.4"; # web container: behind Caddy, main ingress identity
      monitorIP = "10.100.0.5"; # monitor container primary veth address
      webPort = 3010;

      # Shared SQLite dir on the HOST, bind-mounted RW into both containers.
      # Splitting the two services into separate containers means they can no
      # longer share a StateDirectory inside one namespace, so the DB lives here.
      dbDir = "/var/lib/huurhunter";

      # ── FLOATING IP EGRESS ───────────────────────────────────────────────────
      # ALL traffic from the monitor container (${monitorIP}) is SNATed to the FIP
      # — HTTP, headless-Chromium, DNS, uniformly. No app cooperation needed, so it
      # covers the browser (pandomo) path too, which app-side source-binding can't.
      #
      # The FIP list is tracked in the PRIVATE huurhunter repo (nix/egress-fips.nix,
      # exposed as the `egressFips` flake output) — not here, since nixconfig is
      # public. Pure, flows through the flake lock, no impure /etc reads. Empty
      # fallback -> plain NAT (main IP) until a FIP is provisioned. With ONE FIP we
      # SNAT the whole container to it; host-side rotation across multiple FIPs
      # (statistic/nth) is a later concern.
      fips = inputs.huurhunter.egressFips or [ ];
      egressFip = if fips == [ ] then null else builtins.head fips;
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
      containers.hh-web = {
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
      containers.hh-mon = {
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

          services.huurhunter.stateDir = dbDir;
          services.huurhunter-monitor = {
            enable = true;
            browser = true;
          };
        };
      };

      # ── HOST NETWORKING ────────────────────────────────────────────────────────
      # NAT so both containers reach the internet.
      networking.nat = {
        enable = true;
        internalInterfaces = [ "ve-hh-web" "ve-hh-mon" ];
        externalInterface = "enp1s0";
      };

      # Put the Floating IP on the host NIC (Hetzner Cloud delivers FIPs to the
      # server; they must be configured on the main interface). /32.
      networking.interfaces.enp1s0.ipv4.addresses =
        lib.optional (egressFip != null) { address = egressFip; prefixLength = 32; };

      # SNAT the ENTIRE monitor container to the FIP: every packet sourced from
      # ${monitorIP} leaves as the FIP, regardless of protocol (HTTP + Chromium +
      # DNS). Matched BEFORE the generic MASQUERADE from networking.nat, so it wins.
      networking.firewall.extraCommands = lib.optionalString (egressFip != null) ''
        iptables -t nat -A POSTROUTING -s ${monitorIP} -o enp1s0 -j SNAT --to-source ${egressFip}
      '';
      networking.firewall.extraStopCommands = lib.optionalString (egressFip != null) ''
        iptables -t nat -D POSTROUTING -s ${monitorIP} -o enp1s0 -j SNAT --to-source ${egressFip} || true
      '';

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
