final: prev: {
  # use newer version of picom
  picom = prev.picom.overrideAttrs (oldAttrs: {
    src = prev.fetchFromGitHub {
      owner = "yshui";
      repo = "picom";
      rev = "d974367a0446f4f1939daaada7cb6bca84c893ef"; # most recent commit as of 2021-01-08
      sha256 = "sha256-mx60aWR+4hlwMHwEhYSNXZfHfGog5c2aHolMtgkpVVY=";
      fetchSubmodules = true;
    };
  });

  # custom version of xidlehook that adds --not-when-webcam
  # rip jD91mZM2
  xidlehook = prev.xidlehook.overrideAttrs (oldAttrs: rec {
    src = prev.fetchFromGitLab {
      owner = "maxverbeek";
      repo = "xidlehook";
      rev = "adf2758f51cbf1883387db852345498160f88a92"; # master as of 2021-11-14
      sha256 = "sha256-Sk4xMzMVLmgrelkaghuv5HAMx5YdgaDU+VqXwWG+9i8=";
    };

    cargoDeps = oldAttrs.cargoDeps.overrideAttrs (
      prev.lib.const {
        inherit src;
        outputHash = "sha256-Iuri3dOLzrfTzHvwOKcZrVJFotqrGlM6EeuV29yqz+U=";
      }
    );
  });

  eww-wayland = prev.eww-wayland.overrideAttrs (oldAttrs: rec {
    src = final.fetchFromGitHub {
      owner = "ralismark";
      repo = "eww";
      rev = "a82ed62c25ba50f28dc8c3d57efe440d51d6136b";
      hash = "sha256-vxMGAa/RTsMADPK4dM/28SV2ktCT0DenYvGsHZ4IJ8c=";
    };

    cargoHash = "sha256-vxMGAa/RTsMADPK4dM/28SV2ktCT0DenYvGsHZ4IJ7c=";

    buildInputs = oldAttrs.buildInputs ++ [ final.libdbusmenu-gtk3 ];
  });

  arduino-language-server = prev.arduino-language-server.overrideAttrs (old: {
    vendorHash = "sha256-Mu9W92f8ZEaTfJ8YkhKpOvFMB/QzqoxfWkSGWlU/yVM=";
    src = final.fetchFromGitHub {
      # https://github.com/speelbarrow/arduino-language-server
      owner = "speelbarrow";
      repo = "arduino-language-server";
      rev = "6064dc30028ffa096eb541aa8dcfe2522ff5e138";
      hash = "sha256-UlNJsdhkFNgQQeQjHfJlIzX9viX/cZ82omg2wy2SQSM=";
    };
  });

  pycustom.ecida = prev.python3.pkgs.callPackage ./ecida.nix { };

  # FIXME: wait for upstream fix
  slack = prev.slack.overrideAttrs (old: {
    installPhase = old.installPhase + ''
      # Patch the desktop entry to add Wayland flag
      substituteInPlace $out/share/applications/slack.desktop \
        --replace 'bin/slack -s' 'bin/slack -s --ozone-platform=wayland'
    '';
  });

  # cliphist = prev.cliphist.overrideAttrs (old: {
  #   postInstall = ''
  #     cp $src/contrib/cliphist-rofi-img $out/bin/cliphist-rofi-img
  #
  #     chmod +x $out/bin/cliphist-rofi-img
  #   '';
  # });

  # zsh = prev.zsh.overrideAttrs (oldAttrs: {
  #   configureFlags = [ "--enable-zsh-debug" ] ++ oldAttrs.configureFlags;
  # });
}
