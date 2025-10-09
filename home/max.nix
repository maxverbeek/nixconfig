{ pkgs, config, ... }:
{
  imports = [ ./modules ];

  config = {
    xsession.enable = true;

    # custom modules
    modules = {
      i3.enable = true;
      git.enable = true;
      vscode.enable = true;
      kubectl.enable = true;
      autorandr.enable = !config.device.hyprland.enable;
      polybar.enable = !config.device.hyprland.enable;
      rofi.enable = true;
      fuzzel.enable = false;
      rstudio.enable = true;
      screenlocker.enable = true;
      zsh.enable = true;
      alacritty.enable = true;
      direnv.enable = true;
      playerctld.enable = true;
      codex.enable = true;

      polkit.enable = true;

      hyprland.enable = config.device.hyprland.enable;
      waybar.enable = config.device.hyprland.enable;

      picom = {
        enable = !config.device.hyprland.enable;
        experimentalBackends = true;
      };

      # cursor = {
      #   enable = true;
      #   package = pkgs.custom.mcmojave-cursors;
      #   size = 32;
      #   hyprcursor = true;
      #   name = "McMojave-cursors";
      # };
    };

    programs.ssh = {
      enable = true;

      matchBlocks = {
        "pg-gpu.hpc.rug.nl" = {
          user = "f119970";
        };

        "themis" = {
          hostname = "themis.housing.rug.nl";
          user = "themis";
          identityFile = "/home/max/.ssh/laptop_rsa";
        };

        "ssh.dev.azure.com".extraOptions = {
          PubkeyAcceptedKeyTypes = "+ssh-rsa";
          HostkeyAlgorithms = "+ssh-rsa";
        };

        "researchable-1" = {
          hostname = "176.9.32.68";
          user = "root";
          identityFile = "/home/max/.ssh/hetzner_researchable";
        };

        "researchable-2" = {
          hostname = "176.9.48.16";
          user = "root";
          identityFile = "/home/max/.ssh/hetzner_researchable";
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

    fonts.fontconfig = {
      enable = true;
      defaultFonts.serif = [ "Noto Serif" ];
      defaultFonts.sansSerif = [ "Noto Sans" ];
    };

    gtk = {
      enable = true;

      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus";
      };
    };

    # # start 1password on load, maybe I'll make a nix module for this later?
    # systemd.user.services."1password" = {
    #   Unit.Description = "1password tray thingy";
    #   Unit.PartOf = [ "graphical-session.target" ];
    #   Unit.After = [ "graphical-session-pre.target" ];
    #   Service.Type = "exec";
    #   Service.ExecStart = "1password --silent";
    #   Service.KeyringMode = "inherit";
    #   Install.WantedBy = [ "graphical-session.target" ];
    # };
    #
    # home.pointerCursor = {
    #   package = pkgs.custom.mcmojave-cursors;
    #   size = 32;
    #   name = "McMojave-cursors";
    #   gtk.enable = true;
    #   x11.enable = false;
    # };

    home.sessionVariables = {
      JAVA_HOME = "${pkgs.openjdk17}/lib/openjdk";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      EDITOR = "nvim";
    };

    # TODO: really nasty
    home.file.".config/niri/config.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "/home/max/nixconfig/modules/wayland/niri/config.kdl";

    home.file.".jdk/openjdk17".source = pkgs.openjdk17;

    home.stateVersion = "20.09";
    home.packages = with pkgs; [
      # ((steam.override {
      #   extraPkgs = pkgs: [ mesa libxkbcommon gtk3 xorg.libxshmfence ];
      # }).run)
      air
      alsa-utils
      amazon-q-cli
      unstable.argocd
      azure-cli
      binutils
      btop
      bruno
      bruno-cli
      code-cursor
      unstable.claude-code
      chromium
      clockify
      cht-sh
      discord
      dnsutils
      docker-compose
      envsubst
      file
      (pkgs.wrapFirefox (pkgs.firefox-unwrapped.override { pipewireSupport = true; }) { })
      gcc
      glab
      gimp
      gnumake
      htop
      httpie
      inkscape

      jq
      ijq # note 2 packages here

      just
      kdePackages.dolphin
      kdePackages.okular
      kdePackages.kolourpaint
      librsvg
      minikube
      mongodb-compass
      mr
      nautilus
      neo4j-desktop
      neofetch
      nix-index
      nomad
      ngrok
      obsidian
      openssl
      openvpn
      patchelf
      pdftk
      poetry
      pulsemixer
      (python3.withPackages (ps: [ ps.bcrypt ]))
      # python3
      ripgrep
      rsync
      rtorrent
      ruby
      rbenv
      silver-searcher
      slack
      spotify
      sshfs
      tldr
      unp
      unstable.teleport
      unstable.terraform
      unzip
      vlc
      wget
      zathura
      # unstable.zed-editor
      zoom-us

      # latex
      (texlive.combine {
        inherit (texlive)
          scheme-tetex
          latexmk
          biblatex
          tcolorbox
          pdfcol
          upquote
          grffile
          adjustbox
          ;
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
      custom.kiro
      custom.neovim-opener-desktop

      unstable.nurl
      custom.samdump2

      # my own stuff
      # text2url
      xtee

      zen-browser.default

    ];
  };

}
