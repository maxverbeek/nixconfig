{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ags # necessary for cli commands/niri bindings (too lazy to refactor)
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
}
