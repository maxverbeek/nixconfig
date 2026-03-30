{ ... }:
{
  flake.modules.homeManager.development =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        air
        alsa-utils
        amazon-q-cli
        argocd
        azure-cli
        binutils
        btop
        bruno
        bruno-cli
        code-cursor

        chromium
        clockify
        cht-sh
        discord
        dnsutils
        docker-compose
        envsubst
        file
        (wrapFirefox (firefox-unwrapped.override { pipewireSupport = true; }) { })
        gcc
        gitlab-reviewer
        glab
        gimp
        gnumake
        hcloud
        htop
        httpie
        inkscape

        jq
        ijq

        just
        killall
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
        ripgrep
        rsync
        rtorrent
        silver-searcher
        slack
        spotify
        sshfs
        tldr
        unp
        unstable.teleport
        unstable.terraform
        unstable.opentofu
        unzip
        vlc
        wget
        zathura
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
        biber
        pandoc

        jetbrains.idea-oss
        openjdk17
        maven

        nodejs
        yarn

        custom.pngcrop
        custom.kiro
        custom.neovim-opener-desktop

        unstable.nurl
        custom.samdump2

        xtee
        zen-browser
      ];

      home.file.".jdk/openjdk17".source = pkgs.openjdk17;
    };
}
