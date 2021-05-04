{ pkgs, ... }:
{
  imports = [
    ./modules/autorandr.nix
    # ./modules/bspwm.nix
    ./modules/i3.nix
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
        cm = "commit -m";
        co = "checkout";
        a = "add";
        # The !/*/ is a regex that excludes the literal '*' (current branch),
        # and /: gone/ includes branches that are gone on the remote.
        brd = "!git fetch -p && git branch -vv | awk '!/*/ && /: gone]/ {print $1}' | xargs git branch -d";
      };
    };

    programs.vscode = let
      # Move this extension into the nix store, making it immutable
      myvscode = pkgs.unstable.vscode;
    in {
      package = myvscode;
      enable = true;
      extensions = with pkgs.unstable.vscode-extensions; [
        bbenoist.Nix
        # dbaeumer.vscode-eslint # not in unstable yet?
        eamodio.gitlens
        # editorconfig.editorconfig # not in master yet
        # firefox-devtools.vscode-firefox-debug # not in master yet
        ms-azuretools.vscode-docker
        ms-vsliveshare.vsliveshare
        vscodevim.vim
      ];
    };

    services.gnome-keyring.enable = true;

    home.sessionVariables = {
      JAVA_HOME = "${pkgs.openjdk11}/lib/openjdk";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };

    home.stateVersion = "20.09";
    home.packages = with pkgs; [
      ((steam.override { extraPkgs = pkgs: [ mesa libxkbcommon gtk3 xorg.libxshmfence ]; }).run)
      _1password
      alacritty
      binutils
      chromium
      darktable # opening RAW imgs in gimp
      discord
      dnsutils
      docker-compose
      firefox
      file
      gcc
      gimp
      gnumake
      htop
      kubectl
      neofetch
      nix-index
      okular
      patchelf
      pdftk
      responsively-app
      rustup
      slack
      spotify
      unp
      wget
      zathura
      zoom-us

      jetbrains.idea-ultimate
      openjdk11
      maven
      sbt

      nodejs
      yarn

      pngcrop
      figma-linux
    ];
  };
}
