{ config, lib, ... }:

let
  cfg = config.modules.journald-volatile;
  inherit (lib) mkIf mkEnableOption mkOption;
in
{
  options.config.modules.journald-volatile = {
    enable = mkEnableOption "Volatile journald namespace";
    namespace = mkOption {
      type = lib.types.str;
      description = "The name of the journald volatile namespace";
      default = "volatile";
      example = "volatile";
    };
  };

  config = mkIf cfg.enable {
    environment.etc."systemd/journald@${cfg.namespace}.conf" = {
      text = ''
        [Journal]
        storage=volatile
      '';
    };
  };
}
