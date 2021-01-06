{ pkgs, ... }:
{
  imports = [
    ./modules/autorandr.nix
    ./modules/bspwm.nix
    ./modules/polybar.nix
    ./modules/rofi.nix
  ];

  config = {
    xsession.enable = true;

    programs.git = {
      enable = true;

      userEmail = "m4xv3rb33k@gmail.com";
      userName = "Max Verbeek";

      aliases = {
        s = "status";
        cm = "commit";
        co = "checkout";
        a = "add";
      };
    };

    home.stateVersion = "20.09";
    home.packages = with pkgs; [
      alacritty
      chromium
      spotify
    ];
  };
}
