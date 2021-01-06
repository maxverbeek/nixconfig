{ stdenv, lib, ... }:

stdenv.mkDerivation rec {
  name = "fontawsesome-custom";

  phases = [ "installPhase" ];

  fa = ./fontawesome.ttf;
  fa-solid = ./fontawesome-solid.ttf;

  installPhase = ''
    install -D -v -m 644 ${fa} ${fa-solid} -t $out/share/fonts/truetype
  '';

  meta = with lib; {
    description = "Custom fontawesome font";
    platforms = platforms.all;
  };
}
