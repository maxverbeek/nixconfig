{
  nixos.programs.dev-tools =
    { my, pkgs, ... }:
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
      cachePackages.texlive = texliveCombined pkgs;

      environment.systemPackages = with pkgs; [
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
        my.pkgs.gitlab-reviewer
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
        my.pkgs.unstable.mongodb-compass
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
        my.pkgs.unstable.teleport
        my.pkgs.unstable.terraform
        my.pkgs.unstable.opentofu
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

        my.pkgs.pngcrop
        my.pkgs.neovim-opener-desktop

        my.pkgs.unstable.nurl
        my.pkgs.samdump2

        my.pkgs.xtee
        my.pkgs.zen-browser
      ];

      # was home.file.".jdk/openjdk17".source; ours, so L+ keeps it current
      systemd.user.tmpfiles.users.max.rules = [
        "L+ %h/.jdk/openjdk17 - - - - ${pkgs.openjdk17}"
      ];

      # moved here from the desknix and thinkpad host files, where both set
      # these identically as home.sessionVariables
      environment.variables = {
        JAVA_HOME = "${pkgs.openjdk17}/lib/openjdk";
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };

      # was modules/roles/development.nix, which held nothing else
      users.users.max.extraGroups = [
        "plugdev"
        "dialout"
        "adbusers"
      ];
    };
}
