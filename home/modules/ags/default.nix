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
      ExecStart = "${pkgs.ags-max}/bin/ags-max";
      Restart = "always";
      RestartSec = "5s";

      # disable logging for this, because child apps (such as anything i launch
      # with the launcher) will end up logging here, and chrome is super
      # verbose + may log sensitive info
      StandardOutput = "null";
      StandardError = "null";
    };
  };
}
