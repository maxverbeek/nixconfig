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
  };
}
