final: prev: {
  # use newer version of picom
  picom = prev.picom.overrideAttrs (oldAttrs: {
    src = prev.fetchFromGitHub {
      owner = "yshui";
      repo = "picom";
      rev =
        "d974367a0446f4f1939daaada7cb6bca84c893ef"; # most recent commit as of 2021-01-08
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
      rev =
        "adf2758f51cbf1883387db852345498160f88a92"; # master as of 2021-11-14
      sha256 = "sha256-Sk4xMzMVLmgrelkaghuv5HAMx5YdgaDU+VqXwWG+9i8=";
    };

    cargoDeps = oldAttrs.cargoDeps.overrideAttrs (prev.lib.const {
      inherit src;
      outputHash = "sha256-Iuri3dOLzrfTzHvwOKcZrVJFotqrGlM6EeuV29yqz+U=";
    });
  });

  # zsh = prev.zsh.overrideAttrs (oldAttrs: {
  #   configureFlags = [ "--enable-zsh-debug" ] ++ oldAttrs.configureFlags;
  # });
}
