{ ... }:
{
  # NixOS module for xwayland-satellite (X11 compat layer)
  # The option declarations live here; enabling is done in the headful default.nix
  flake.modules.nixos.xwayland-satellite =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.modules.xwayland-satellite;
    in
    {
      options.modules.xwayland-satellite = {
        enable = lib.mkEnableOption "Enable XWayland-satellite";
        package = lib.mkOption {
          type = lib.types.package;
          description = "Xwayland-satellite package";
          default = pkgs.unstable.xwayland-satellite;
        };
        address = lib.mkOption {
          type = lib.types.str;
          description = "The address of the display server";
          default = ":0";
        };
      };

      config.systemd.user.services = lib.mkIf cfg.enable {
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
            ExecStart = "${cfg.package}/bin/xwayland-satellite ${cfg.address}";
            StandardOutput = "journal";
            Restart = "on-failure";
          };
        };
      };
    };
}
