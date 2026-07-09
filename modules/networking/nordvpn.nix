# NordVPN service. Replicates what the upstream .deb's systemd units + postinst
# do: a socket-activated daemon running as group `nordvpn`, a writable state dir
# seeded with the shipped data files, and the CLI on PATH.
#
# Usage after rebuild:  nordvpn login  ->  nordvpn connect
# The user must be in the `nordvpn` group to talk to the daemon socket.
{ ... }:
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    let
      nordvpn = pkgs.custom.nordvpn;
    in
    {
      users.groups.nordvpn = { };

      environment.systemPackages = [ nordvpn ];

      # /run/nordvpn is created by the socket unit; /var/lib/nordvpn holds the
      # daemon's mutable state and must be seeded with the shipped data files
      # (servers.dat, countries.dat, ovpn templates) since the store is read-only.
      #
      # The daemon forks helper binaries (norduserd, nordfileshare, openvpn) by
      # their hardcoded FHS path /usr/lib/nordvpn/<helper> — the proprietary
      # binary can't be told about the Nix store location. Without this the
      # browser reports "logged in" but the daemon never receives the token
      # (norduserd never starts), so `nordvpn account` keeps saying "not logged
      # in". Symlink the whole store lib dir onto the FHS path so every helper
      # (login handoff, fileshare, OpenVPN fallback) resolves.
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
