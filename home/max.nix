{ pkgs, ... }:
{
  imports = [
    ./modules/autorandr.nix
    ./modules/bspwm.nix
    ./modules/picom
    ./modules/polybar.nix
    ./modules/rofi.nix
  ];

  config = {
    xsession.enable = true;
    xsession.pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      defaultCursor = "left_ptr";
    };

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
      docker-compose
      htop
      kubectl
      slack
      spotify
    ];
  };
}
