{ pkgs, config, ... }: {
  imports = [ ./modules ];

  config = {
    xsession.enable = true;
    xsession.pointerCursor = {
      package = pkgs.custom.mcmojave-cursors;
      name = "McMojave-cursors";
      defaultCursor = "left_ptr";
    };

    # custom modules
    modules = {
      i3.enable = true;
      git.enable = true;
      vscode.enable = true;
      kubectl.enable = true;
      autorandr.enable = true;
      polybar.enable = true;
      rofi.enable = true;
      screenlocker.enable = true;
      zsh.enable = true;
      alacritty.enable = true;
      direnv.enable = true;
      playerctld.enable = true;

      picom = {
        enable = true;
        experimentalBackends = true;
      };
    };

    programs.ssh = {
      enable = true;

      matchBlocks = {
        "pg-gpu.hpc.rug.nl" = { user = "f119970"; };

        "themis" = {
          hostname = "themis.housing.rug.nl";
          user = "themis";
          identityFile = "/home/max/.ssh/laptop_rsa";
        };
      };
    };

    programs.gpg.enable = true;
    programs.go = {
      enable = true;
      goPath = "go";
      goBin = "go/bin";
    };

    services.gpg-agent.enable = true;
    services.flameshot.enable = true;

    home.sessionVariables = {
      JAVA_HOME = "${pkgs.openjdk17}/lib/openjdk";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      EDITOR = "nvim";
    };

    home.file.".jdk/openjdk17".source = pkgs.openjdk17;

    home.stateVersion = "20.09";
    home.packages = with pkgs; [
      # ((steam.override {
      #   extraPkgs = pkgs: [ mesa libxkbcommon gtk3 xorg.libxshmfence ];
      # }).run)

      _1password
      air
      binutils
      chromium
      cht-sh
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

      jq
      ijq # note 2 packages here

      kubernetes-helm
      librsvg
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
      rsync
      rtorrent
      ruby
      rustup
      silver-searcher
      slack
      sshfs
      spotify
      tldr
      teams
      unp
      unzip
      vlc
      wget
      zathura
      zoom-us

      # latex
      (texlive.combine { inherit (texlive) scheme-medium latexmk; })
      pandoc

      jetbrains.idea-ultimate
      openjdk11
      maven

      nodejs
      yarn

      custom.pngcrop
      # custom.responsively-app
      # custom.figma-linux

      oli.screencapture-scripts
    ];
  };
}
