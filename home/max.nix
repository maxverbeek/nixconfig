{ pkgs, ... }:
{
  imports = [
    ./modules/autorandr.nix
    ./modules/bspwm.nix
    ./modules/picom
    ./modules/polybar.nix
    ./modules/rofi.nix
    ./modules/zsh.nix
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

      extraConfig = {
        pull.rebase = "false";
      };

      aliases = {
        s = "status";
        cm = "commit";
        co = "checkout";
        a = "add";
      };
    };

    programs.vscode.enable = true;

    home.sessionVariables = {
      JAVA_HOME = "${pkgs.openjdk11}/lib/openjdk";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };

    home.stateVersion = "20.09";
    home.packages = with pkgs; [
      ((steam.override { extraPkgs = pkgs: [ mesa libxkbcommon ]; }).run)
      _1password
      alacritty
      chromium
      darktable # opening RAW imgs in gimp
      discord
      dnsutils
      docker-compose
      firefox
      gimp
      gnumake
      htop
      kubectl
      neofetch
      patchelf
      pdftk
      responsively-app
      slack
      spotify
      unp
      zathura
      zoom-us

      jetbrains.idea-ultimate
      openjdk11
      maven
      sbt

      nodejs
      yarn
    ];
  };
}
