{ inputs, ... }:
{
  flake.modules.homeManager.headful =
    { pkgs, ... }:
    {
      # The wrapper is on PATH so niri binds can say `barbell ipc call menu
      # open` without knowing any store path.
      home.packages = [ inputs.barbell.packages.${pkgs.system}.default ];

      systemd.user.services.barbell = {
        Unit = {
          Description = "barbell (quickshell) bar";
          Wants = [ "niri.service" ];
          After = [ "niri.service" ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${inputs.barbell.packages.${pkgs.system}.default}/bin/barbell";
          Restart = "always";
          RestartSec = "1s";
        };
      };
    };
}
