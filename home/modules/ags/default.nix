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

      # disable logging for this, because child apps (such as anything i launch
      # with the launcher) will end up logging here, and chrome is super
      # verbose + may log sensitive info
      StandardOutput = "null";
      StandardError = "null";

      # Add environment variables for xwayland-satellite so that stuff started
      # through here can use Xwayland through this.
      # FIXME: the value for this is set in system configuration but i cannot
      # access that from home configuration
      Environment = [ "DISPLAY=:0" ];
    };
  };
}
