{ pkgs, config, ... }:
{
  imports = [
    ./modules/autorandr.nix
    # ./modules/bspwm.nix
    ./modules/i3.nix
    ./modules/nvim
    ./modules/kubectl.nix
    ./modules/picom
    ./modules/polybar.nix
    ./modules/rofi.nix
    ./modules/screenlocker
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
        push.default = "current";
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

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;

      nix-direnv = {
        enable = true;
        enableFlakes = true;
      };
    };

    programs.gpg = {
      enable = true;
    };

    programs.kubectl = {
      enable = true;
    };

    programs.go = {
      enable = true;
      goPath = "go";
      goBin = "go/bin";
    };

    services.gpg-agent = {
      enable = true;
    };

    home.sessionVariables = {
      JAVA_HOME = "${pkgs.openjdk16}/lib/openjdk";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      EDITOR = "nvim";
    };

    home.file.".jdk/openjdk11".source = pkgs.openjdk11;
    home.file.".jdk/openjdk16".source = pkgs.openjdk16;

    home.stateVersion = "20.09";
    home.packages = with pkgs; [
      ((steam.override { extraPkgs = pkgs: [ mesa libxkbcommon gtk3 xorg.libxshmfence ]; }).run)
      _1password
      binutils
      chromium
      custom.responsively-app
      darktable # opening RAW imgs in gimp
      discord
      dnsutils
      docker-compose
      file
      firefox
      gcc
      gimp
      gnumake
      htop
      httpie
      jq ijq # note 2 packages here
      kubernetes-helm
      minikube
      neofetch
      nix-index
      okular
      openvpn
      patchelf
      pdftk
      pulsemixer
      python3
      ripgrep
      rtorrent
      ruby
      rustup
      silver-searcher
      slack
      spotify
      tldr
      ulauncher
      unp
      unzip
      vlc
      wget
      zathura
      zoom-us

      # latex
      (texlive.combine {
        inherit (texlive) scheme-medium latexmk;
      })
      pandoc

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
