{
  # No NixOS counterpart to home-manager's services.awww, so the user unit is
  # written out by hand here.
  nixos.programs.awww =
    { lib, pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.awww ];

      systemd.user.services.awww = {
        description = "awww-daemon";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
        path = [ pkgs.awww ];
        serviceConfig = {
          ExecStart = lib.getExe' pkgs.awww "${pkgs.awww.meta.mainProgram}-daemon";
          Restart = "always";
          RestartSec = 10;
        };
      };
    };
}
