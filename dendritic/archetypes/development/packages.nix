{ ... }:
{
  flake.modules.homeManager.dev-packages =
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

        unstable.claude-code
        unstable.claude-code-acp

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
        (python3.withPackages (ps: [ ps.bcrypt ]))
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

        jetbrains.idea-community
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
        zen-browser.default
      ];

      home.file.".jdk/openjdk17".source = pkgs.openjdk17;
    };
}
