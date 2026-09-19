{
  # `my.guests.<name>`: a NixOS system run by this host, today as an nspawn
  # container. Anything the module does not cover is set on `containers.<name>`
  # directly and merges with what is generated here.
  nixos.system.guests =
    {
      config,
      lib,
      my,
      ...
    }:
    let
      cfg = config.my.guests;
      subnet = "10.100.0";
      address = guest: "${subnet}.${toString guest.ip}";

      # One path on both sides of the mount, so the guest's `secrets` argument
      # is the host path and nothing is renamed.
      secretPath = guest: attr: "/run/guest-secrets/${guest}/${attr}";
      secretName = guest: attr: "${guest}-${attr}";
      forSecrets = f: lib.concatMapAttrs (guest: g: lib.mapAttrs' (f guest) g.secrets) cfg;
    in
    {
      options.my.guests = lib.mkOption {
        default = { };
        description = "Containers on the ${subnet}.0/24 subnet, NATed out of the host and proxied by Caddy.";
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              ip = lib.mkOption {
                type = lib.types.ints.between 2 254;
                description = "Last octet of the guest's address; the host is .1.";
              };
              secrets = lib.mkOption {
                type = lib.types.attrsOf lib.types.path;
                default = { };
                description = ''
                  agenix ciphertexts by local name. Each is decrypted on the host,
                  bind-mounted read-only, and reachable inside the guest's `config`
                  as the `secrets.<name>` module argument.
                '';
              };
              proxy = lib.mkOption {
                type = lib.types.attrsOf lib.types.port;
                default = { };
                description = "Caddy virtual host -> guest port. The port is opened in the guest firewall.";
              };
              modules = lib.mkOption {
                type = lib.types.listOf lib.types.deferredModule;
                default = [ ];
                description = "The guest's NixOS modules; they receive `my` and `secrets` as arguments.";
              };
            };
          }
        );
      };

      config = lib.mkIf (cfg != { }) {
        assertions = [
          {
            assertion = lib.allUnique (lib.mapAttrsToList (_: g: g.ip) cfg);
            message = "guests: duplicate ip";
          }
        ];

        containers = lib.mapAttrs (name: guest: {
          autoStart = true;
          privateNetwork = true;
          hostAddress = "${subnet}.1";
          localAddress = address guest;
          specialArgs = {
            inherit my;
            secrets = lib.mapAttrs (attr: _: secretPath name attr) guest.secrets;
          };
          bindMounts = lib.mapAttrs' (
            attr: _:
            lib.nameValuePair (secretPath name attr) {
              hostPath = config.age.secrets.${secretName name attr}.path;
              isReadOnly = true;
            }
          ) guest.secrets;
          config = {
            imports = guest.modules;
            system.stateVersion = "25.11";
            networking.useHostResolvConf = false;
            networking.nameservers = [
              "1.1.1.1"
              "8.8.8.8"
            ];
            networking.firewall.allowedTCPPorts = lib.attrValues guest.proxy;
          };
        }) cfg;

        # symlink = false: a /run/agenix symlink would dangle across agenix
        # generations inside the mount; a plain file is mounted by inode. The
        # explicit path keeps agenix's /run/agenix/<name> generation symlink intact.
        age.secrets = forSecrets (
          guest: attr: file:
          lib.nameValuePair (secretName guest attr) {
            inherit file;
            symlink = false;
            path = secretPath guest attr;
          }
        );

        # externalInterface is the host's to set.
        networking.nat.enable = true;
        networking.nat.internalIPs = [ "${subnet}.0/24" ];

        services.caddy.enable = true;
        services.caddy.virtualHosts = lib.concatMapAttrs (
          _: guest:
          lib.mapAttrs (_: port: {
            extraConfig = "reverse_proxy ${address guest}:${toString port}\n";
          }) guest.proxy
        ) cfg;
        networking.firewall.allowedTCPPorts = [
          80
          443
        ];
      };
    };
}
