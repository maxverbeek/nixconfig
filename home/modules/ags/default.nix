{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    bun
    libdbusmenu-gtk3
    dart-sass
    fd
    brightnessctl
    swww
    pavucontrol
    networkmanager
    gtk3
    hyprpicker
    swappy
    wayshot
  ];

  programs.ags = {
    enable = true;

    extraPackages = with pkgs.astal; [
      io
      apps
      battery
      bluetooth
      network
      mpris
      notifd
      tray
      wireplumber
    ];
  };

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
      ExecStart = "${config.programs.ags.finalPackage}/bin/ags run";
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
