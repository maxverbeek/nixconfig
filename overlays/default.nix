{ pkgs, lib, ... }:

let customOverlays = final: prev: {
  fa-custom = final.callPackage (import ./fontawesome-custom) {};

  # use newer version of picom
  picom = prev.picom.overrideAttrs (oldAttrs: {
    src = prev.fetchFromGitHub {
      owner = "yshui";
      repo = "picom";
      rev = "d974367a0446f4f1939daaada7cb6bca84c893ef"; # most recent commit as of 2021-01-08
      sha256 = "9b1eb469647ee21970307c0485848d5d97c77c6a20e5cd9a1e894cb609295556";
      fetchSubmodules = true;
    };
  });

};
in
{
  nixpkgs.overlays = [ customOverlays ];
}
