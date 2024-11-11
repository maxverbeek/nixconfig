{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption;
  cfg = config.modules.xwayland-satellite;
in
{
  options.modules.xwayland-satellite = {
    enable = mkEnableOption "Enable XWayland-satellite";
    package = mkOption {
      type = lib.types.package;
      description = "Xwayland-satellite package";
      default = pkgs.unstable.xwayland-satellite;
      example = lib.literalExpression "pkgs.unstable.xwayland-satellite";
    };
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
        ExecStart = "${cfg.package}/bin/xwayland-satellite :0";
        StandardOutput = "journal";
        Restart = "on-failure";
      };
    };
  };
}
