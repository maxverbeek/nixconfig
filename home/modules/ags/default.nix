{ pkgs, ... }:
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
}
