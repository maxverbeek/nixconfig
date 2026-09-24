{
  nixos.programs.mictap =
    { my, pkgs, ... }:
    {
      environment.systemPackages = [ my.pkgs.mictap ];

      systemd.user.services.mictap = {
        description = "mictap meeting recorder";
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        path = [
          pkgs.pipewire
          pkgs.libnotify
        ];
        serviceConfig = {
          ExecStart = "${my.pkgs.mictap}/bin/mictap daemon";
          Restart = "on-failure";
          RestartSec = 2;
        };
      };
    };
}
