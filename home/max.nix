{ pkgs, config, ... }:
{
  imports = [
    ./modules/autorandr.nix
    # ./modules/bspwm.nix
    ./modules/i3.nix
    ./modules/nvim
    ./modules/picom
    ./modules/polybar.nix
    ./modules/rofi.nix
    ./modules/screenlocker.nix
    ./modules/zsh.nix
  ];

  config = {
    xsession.enable = true;
    xsession.pointerCursor = {
      package = pkgs.custom.mcmojave-cursors;
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

        difflast = "diff HEAD^";
      };
    };

    programs.alacritty = {
      enable = true;
      settings = {
        font.size = config.device.termFontSize;
      };
    };

    programs.vscode = {
      package = pkgs.vscode-fhs;
      enable = true;
      extensions = with pkgs.vscode-extensions; [
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

    home.sessionVariables = {
      JAVA_HOME = "${pkgs.openjdk11}/lib/openjdk";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };

    home.stateVersion = "20.09";
    home.packages = with pkgs; [
      ((steam.override { extraPkgs = pkgs: [ mesa libxkbcommon gtk3 xorg.libxshmfence ]; }).run)
      _1password
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
      go
      htop
      kubectl
      kubernetes-helm
      minikube
      neofetch
      nix-index
      okular
      openvpn
      custom.responsively-app
      patchelf
      pdftk
      python3
      ripgrep
      rtorrent
      rustup
      silver-searcher
      slack
      spotify
      tldr
      ulauncher
      unp
      vlc
      wget
      zathura
      zoom-us

      unstable._1password-gui

      jetbrains.idea-ultimate
      openjdk11
      maven
      (sbt.override { jre = jre8; })

      nodejs
      yarn

      custom.pngcrop
      custom.figma-linux

      oli.screencapture-scripts
    ];
  };
}
