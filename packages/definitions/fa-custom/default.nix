{ stdenv, lib, ... }:

stdenv.mkDerivation rec {
  name = "fontawsesome-custom";

  phases = [ "installPhase" ];

  fa = ./fontawesome.ttf;
  fa-solid = ./fontawesome-solid.ttf;
  fa-brands = ./fontawesome-brands.otf;

  installPhase = ''
    install -D -v -m 444 ${fa} ${fa-solid} -t $out/share/fonts/truetype
    install -D -v -m 444 ${fa-brands} -t $out/share/fonts/opentype
  '';

  meta = with lib; {
    description = "Custom fontawesome font";
    platforms = platforms.all;
  };
}
