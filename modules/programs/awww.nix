{
  # No NixOS services.awww exists, so the user unit is written out by hand.
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
