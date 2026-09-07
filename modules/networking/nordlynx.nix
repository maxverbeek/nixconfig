# NordVPN over plain WireGuard ("NordLynx") without the proprietary daemon.
#
# Two consumers, two shapes:
#  - networkmanager: one NetworkManager profile per server, all off by default;
#    toggle in the applet or `nmcli con up "NordLynx NL Amsterdam"`. Full
#    tunnel with Nord DNS. Laptops.
#  - bind: a wg-quick interface to ONE server whose routes live in a private
#    table; only traffic SOURCED from the tunnel address uses it
#    (`curl --interface <addr>`). Everything else keeps its normal egress. Servers.
#
# Getting the key: generate an access token in Nord Account > Manual setup, then
#   curl -s -u token:$TOKEN https://api.nordvpn.com/v1/users/services/credentials | jq -r .nordlynx_private_key
# Picking servers (one public key per country, only endpoints differ):
#   curl -sg 'https://api.nordvpn.com/v1/servers/recommendations?filters[country_id]=153&filters[servers_technologies][identifier]=wireguard_udp&limit=4'
{ ... }:
{
  flake.modules.nixos.nordlynx =
    { config, lib, ... }:
    let
      cfg = config.services.nordlynx;
      nordDns = [ "103.86.96.100" "103.86.99.100" ];
      table = "51820";
      addr = lib.head (lib.splitString "/" cfg.address);
      serverType = lib.types.submodule {
        options = {
          endpoint = lib.mkOption { type = lib.types.str; };
          publicKey = lib.mkOption { type = lib.types.str; };
        };
      };
      nl = "5p4RkybdRU5uaDi90eu4KZPTFif0lKCg4Qp6t1c4F30=";
    in
    {
      options.services.nordlynx = {
        enable = lib.mkEnableOption "NordLynx WireGuard tunnel";
        mode = lib.mkOption {
          type = lib.types.enum [ "networkmanager" "bind" ];
          description = "networkmanager: toggleable full-tunnel NM profiles. bind: source-bound wg-quick interface to one server.";
        };
        servers = lib.mkOption {
          type = lib.types.attrsOf serverType;
          description = "Nord WireGuard servers by display name. Recommendations as of 2026-09-07.";
          default = {
            "NL Amsterdam" = { endpoint = "186.247.163.6:51820"; publicKey = nl; }; # nl1252
            "NL Amsterdam 2" = { endpoint = "186.247.163.10:51820"; publicKey = nl; }; # nl1254
            "DE Hamburg" = { endpoint = "187.40.53.116:51820"; publicKey = "qJb7+jCxGN8MAcSTKcDvDE81XobRBv1mu+phcB3zOGw="; }; # de1543
            "BE Brussels" = { endpoint = "187.13.21.76:51820"; publicKey = "VSa6XYcD279ahd3IuEiUH6VpXn0+h+kWrD4OcN1ExUs="; }; # be316
            "UK London" = { endpoint = "217.146.92.158:51820"; publicKey = "K53l2wOIHU3262sX5N/5kAvCvt4r55lNui30EbvaDlE="; }; # uk2265
            "US New York" = { endpoint = "138.199.52.107:51820"; publicKey = "0/x2PdBGfcIGr0ayFPFFjxcEEyhrlBRjR4kMcfwXJTU="; }; # us8368
            "SE Stockholm" = { endpoint = "187.15.110.3:51820"; publicKey = "EdKGlWFPgosHt/9vGBfcIv39umAsMrvbOxw9c3CZMw4="; }; # se650
            "CH Zurich" = { endpoint = "187.15.170.129:51820"; publicKey = "SqAWBSVdnUJ859Bz2Nyt82rlSebMwPgvwQxIb1DzyF8="; }; # ch499
          };
        };
        server = lib.mkOption {
          type = lib.types.str;
          default = "NL Amsterdam";
          description = "bind mode: which entry of `servers` to tunnel to.";
        };
        address = lib.mkOption {
          type = lib.types.str;
          default = "10.5.0.2/32";
          description = "Tunnel address. Nord hands every NordLynx client 10.5.0.2.";
        };
        privateKeyFile = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "bind mode: file holding the NordLynx private key.";
        };
        environmentFile = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "networkmanager mode: env file defining NORDLYNX_PRIVATE_KEY.";
        };
      };

      config = lib.mkIf cfg.enable (lib.mkMerge [
        (lib.mkIf (cfg.mode == "bind") {
          assertions = [
            { assertion = cfg.privateKeyFile != null; message = "services.nordlynx.privateKeyFile is required in bind mode"; }
            { assertion = cfg.servers ? ${cfg.server}; message = "services.nordlynx.server '${cfg.server}' is not in services.nordlynx.servers"; }
          ];
          networking.wg-quick.interfaces.nordlynx = {
            address = [ cfg.address ];
            privateKeyFile = cfg.privateKeyFile;
            inherit table;
            # rp_filter stays happy: the reverse lookup swaps src/dst, so the
            # "from <addr>" rule matches replies too and resolves to this iface.
            postUp = "ip rule add from ${addr} lookup ${table}";
            preDown = "ip rule del from ${addr} lookup ${table}";
            peers = [
              {
                inherit (cfg.servers.${cfg.server}) endpoint publicKey;
                allowedIPs = [ "0.0.0.0/0" ];
                persistentKeepalive = 25;
              }
            ];
          };
        })
        (lib.mkIf (cfg.mode == "networkmanager") {
          assertions = [ { assertion = cfg.environmentFile != null; message = "services.nordlynx.environmentFile is required in networkmanager mode"; } ];
          networking.networkmanager.ensureProfiles = {
            environmentFiles = [ cfg.environmentFile ];
            profiles = lib.mapAttrs' (name: s: lib.nameValuePair "nordlynx-${lib.toLower (lib.replaceStrings [ " " ] [ "-" ] name)}" {
              connection = {
                id = "NordLynx ${name}";
                type = "wireguard";
                interface-name = "nordlynx";
                autoconnect = false;
              };
              wireguard.private-key = "$NORDLYNX_PRIVATE_KEY";
              "wireguard-peer.${s.publicKey}" = {
                endpoint = s.endpoint;
                allowed-ips = "0.0.0.0/0";
                persistent-keepalive = "25";
              };
              ipv4 = {
                method = "manual";
                address1 = cfg.address;
                dns = lib.concatStringsSep ";" nordDns + ";";
                dns-priority = "-10"; # beat the LAN resolver while the tunnel is up
              };
              ipv6.method = "disabled";
            }) cfg.servers;
          };
        })
      ]);
    };
}
