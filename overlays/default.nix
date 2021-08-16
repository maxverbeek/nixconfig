final: prev:
{
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
      rev = "5091c0c9f2b542e787ba641254a47efa14c1775d"; # master as of 2021-08-16
      sha256 = "sha256-9JQSaoJZijKs2txXwCd0jPFg+eFhoZyifb7j91fwYyw=";
    };

    cargoDeps = oldAttrs.cargoDeps.overrideAttrs (prev.lib.const {
      inherit src;
      outputHash = "sha256-Iuri3dOLzrfTzHvwOKcZrVJFotqrGlM6EeuV29yqz+U=";
    });
  });
}
