{
  flake.modules.homeManager.wayscriber =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.wayscriber ];

      systemd.user.services.wayscriber = {
        Unit = {
          Description = "Wayscriber";
          Wants = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.wayscriber}/bin/wayscriber --daemon";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 5;
        };
      };

      programs.wlr-which-key.config.menu = [
        {
          key = "a";
          desc = "Annotate screen";
          cmd = "pkill -SIGUSR1 wayscriber";
        }
      ];
    };
}
