{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.xwayland-satellite;
in
{
  options.modules.xwayland-satellite = {
    enable = mkEnableOption "Enable XWayland-satellite";
  };

  config.systemd.user.services = mkIf cfg.enable {
    xwayland-satellite = {
      description = "XWayland Satellite";
      bindsTo = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      requisite = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];

      startLimitIntervalSec = 10;
      startLimitBurst = 5;

      serviceConfig = {
        Type = "notify";
        NotifyAccess = "all";
        ExecStart = "${pkgs.unstable.xwayland-satellite}/bin/xwayland-satellite :0";
        StandardOutput = "journal";
        Restart = "on-failure";
      };
    };
  };
}
