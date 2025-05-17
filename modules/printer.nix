{ config, lib, ... }:
let
  cfg = config.roles.printer;
in
{
  options.roles.printer = {
    enable = lib.mkEnableOption "Enable printer module";
  };

  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
