{ pkgs, config, ... }: {
  imports = [ ./modules ];

  config = {
    xsession.enable = true;

    # custom modules
    modules = {
      i3.enable = true;
      git.enable = true;
      vscode.enable = true;
      kubectl.enable = true;
      autorandr.enable = true;
      polybar.enable = !config.device.hyprland.enable;
      rofi.enable = true;
      rstudio.enable = false;
      screenlocker.enable = true;
      zsh.enable = true;
      alacritty.enable = true;
      direnv.enable = true;
      playerctld.enable = true;

      hyprland.enable = config.device.hyprland.enable;

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

        "ssh.dev.azure.com".extraOptions = {
          PubkeyAcceptedKeyTypes = "+ssh-rsa";
          HostkeyAlgorithms = "+ssh-rsa";
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
    services.flameshot.enable = !config.device.hyprland.enable;

    gtk = {
      enable = true;
      cursorTheme = {
        package = pkgs.custom.mcmojave-cursors;
        name = "McMojave-cursors";
      };

      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus";
      };
    };

    # home.pointerCursor = {
    #   x11.enable = true;
    #   x11.defaultCursor = "left_ptr";
    # };

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
      _1password-gui
      air
      unstable.argocd
      azure-cli
      binutils
      chromium
      cht-sh
      discord
      dolphin
      dnsutils
      docker-compose
      envsubst
      file
      firefox
      gcc
      gimp
      gnumake
      htop
      httpie
      inkscape

      jq
      ijq # note 2 packages here

      kubernetes-helm
      kolourpaint
      librsvg
      minikube
      neofetch
      neo4j-desktop
      nix-index
      okular
      openssl
      openvpn
      patchelf
      pdftk
      pulsemixer
      python3
      ripgrep
      rsync
      rtorrent
      ruby
      silver-searcher
      slack
      sshfs
      spotify
      unstable.teleport
      unstable.terraform
      tldr
      unp
      unzip
      vlc
      wget
      zathura
      zoom-us

      # latex
      (texlive.combine {
        inherit (texlive)
          scheme-tetex latexmk biblatex tcolorbox pdfcol upquote grffile
          adjustbox;
      })
      biber # required for biblatex
      pandoc

      jetbrains.idea-community
      openjdk17
      maven

      nodejs
      yarn

      custom.pngcrop
      # custom.responsively-app
      # custom.figma-linux

      unstable.nurl
      custom.samdump2

      # my own stuff
      text2url
    ];
  };
}
