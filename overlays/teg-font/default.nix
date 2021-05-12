{ stdenv, lib, ... }:

stdenv.mkDerivation rec {
  name = "teg-font";

  phases = [ "installPhase" ];

  ultra = ./TEG-Ultra.otf;
  black = ./TEG-Black.otf;
  bold = ./TEG-Bold.otf;
  medium = ./TEG-Medium.otf;
  regular = ./TEG-Regular.otf;
  light = ./TEG-Light.otf;
  extralight = ./TEG-ExtraLight.otf;

  allfonts = [ ultra black bold medium regular light extralight ];


  installPhase = with lib; ''
    install -D -v -m 444 ${concatStringsSep " " allfonts} -t $out/share/fonts/opentype
  '';

  meta = with lib; {
    description = "Custom TEG font";
    platforms = platforms.all;
  };
}
