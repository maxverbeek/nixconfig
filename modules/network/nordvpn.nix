# Replicates the upstream .deb's systemd units + postinst: socket-activated
# daemon in group `nordvpn`, a writable state dir seeded with the shipped data
# files, and the CLI on PATH. Then: `nordvpn login` -> `nordvpn connect`.
{
  nixos.network.nordvpn =
    { my, pkgs, ... }:
    let
      nordvpn = my.pkgs.nordvpn;
    in
    {
      users.groups.nordvpn = { };
      users.users.max.extraGroups = [ "nordvpn" ];

      environment.systemPackages = [ nordvpn ];

      # The daemon forks its helpers (norduserd, nordfileshare, openvpn) by the
      # hardcoded FHS path /usr/lib/nordvpn/<helper> and cannot be told about the
      # store, hence the symlink. Without it the browser says "logged in" but
      # norduserd never starts, so `nordvpn account` stays "not logged in".
      # /var/lib/nordvpn is the mutable state dir, seeded below.
      systemd.tmpfiles.rules = [
        "d /var/lib/nordvpn      0750 root nordvpn - -"
        "d /var/lib/nordvpn/data 0750 root nordvpn - -"
        "L+ /usr/lib/nordvpn - - - - ${nordvpn}/lib/nordvpn"
      ];

      systemd.sockets.nordvpnd = {
        description = "NordVPN Daemon Socket";
        wantedBy = [ "sockets.target" ];
        socketConfig = {
          ListenStream = "/run/nordvpn/nordvpnd.sock";
          SocketGroup = "nordvpn";
          SocketMode = "0660";
          DirectoryMode = "0750";
          RemoveOnStop = true;
        };
      };

      systemd.services.nordvpnd = {
        description = "NordVPN Daemon";
        wantedBy = [ "multi-user.target" ];
        requires = [ "nordvpnd.socket" ];
        after = [
          "network-online.target"
          "nordvpnd.socket"
        ];
        wants = [ "network-online.target" ];

        # Seed read-only data files from the store into the mutable state dir.
        preStart = ''
          for f in ${nordvpn}/share/data/*; do
            install -Dm640 -g nordvpn "$f" "/var/lib/nordvpn/data/$(basename "$f")"
          done
        '';

        serviceConfig = {
          ExecStart = "${nordvpn}/bin/nordvpnd";
          NonBlocking = true;
          KillMode = "process";
          Restart = "always";
          RestartSec = 5;
          Group = "nordvpn";
          RuntimeDirectory = "nordvpn";
          RuntimeDirectoryMode = "0750";
          RuntimeDirectoryPreserve = "yes";
        };
      };

      # The daemon manages its own kernel routing and iptables rules for the
      # tunnel + killswitch; it needs the tun module and unrestricted rule mgmt.
      boot.kernelModules = [ "tun" ];
    };
}
