{ ... }:
let
  texliveCombined =
    pkgs:
    pkgs.texlive.combine {
      inherit (pkgs.texlive)
        scheme-tetex
        latexmk
        biblatex
        tcolorbox
        pdfcol
        upquote
        grffile
        adjustbox
        ;
    };
in
{
  # texlive.combine is a slow local rebuild on every host; pre-build it.
  perSystem =
    { pkgs, ... }:
    {
      cachePackages.texlive = texliveCombined pkgs;
    };

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
        gh
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
        # stable's build hits a wrap-gapps-hook bug; drop the unstable pin
        # once nixos-26.05 builds it again
        unstable.mongodb-compass
        mr
        nautilus
        fastfetch
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

        # latex (definition shared with cachePackages above)
        (texliveCombined pkgs)
        biber
        pandoc

        openjdk17
        maven

        nodejs
        yarn

        custom.gog
        custom.pngcrop
        custom.neovim-opener-desktop

        unstable.nurl
        custom.samdump2

        xtee
        zen-browser
      ];

      home.file.".jdk/openjdk17".source = pkgs.openjdk17;
    };
}
