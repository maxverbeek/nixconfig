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
      package = pkgs.mcmojave-cursors;
      name = "McMojave-cursors";
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

    programs.vscode.enable = true;

    home.stateVersion = "20.09";
    home.packages = with pkgs; [
      _1password
      alacritty
      chromium
      docker-compose
      htop
      firefox
      kubectl
      slack
      spotify
    ];
  };
}
