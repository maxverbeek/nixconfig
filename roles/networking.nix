{ config, lib, ... }:
let
  cfg = config.roles.networking;
in
{
  options = {
    enable = lib.mkEnableOption "Enable networking module";
    hostname = lib.mkOption {
      type = lib.types.string;
      description = "Hostname used for networking";
    };
  };

  config = lib.mkIf cfg.enable {

    networking = {
      hostname = cfg.hostname;

      extrahosts = ''
        127.0.0.1 keycloak
        127.0.0.1 s3
      '';

      networkmanager.enable = true;

      firewall.enable = true;
      firewall.allowedTCPPorts = [
        3000
        3100
        3200
      ];
    };

    services.resolved = {
      enable = true;
      fallbackDns = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
    };

    systemd.services.NetworkManager-wait-online.enable = false;

    users.users.max.extraGroups = [ "networkmanager" ];
  };
}
