{ ... }:
{
  flake.modules.homeManager.ags =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ags
        bun
        fd
        brightnessctl
        networkmanager
        swappy
        wayshot
      ];

      systemd.user.services.ags = {
        Unit = {
          Description = "Astal (ags) bar";
          Wants = [ "niri.service" ];
          After = [ "niri.service" ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.agsmax}/bin/maxags";
          Restart = "always";
          RestartSec = "1s";
        };
      };
    };
}
