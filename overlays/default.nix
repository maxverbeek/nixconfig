{ pkgs, lib, ... }:

let customOverlays = final: prev: {
  fa-custom = final.callPackage (import ./fontawesome-custom) {};

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

};
in
{
  nixpkgs.overlays = [ customOverlays ];
}
