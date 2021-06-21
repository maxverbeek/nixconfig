{ stdenvNoCC, fetchFromGitHub, inkscape, xcursorgen }:

stdenvNoCC.mkDerivation rec {
  name = "volantes-cursors";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "varlesh";
    repo = "volantes-cursors";
    rev = "master";
    sha256 = "sha256-irMN/enoo90nYLfvSOScZoYdvhZKvqqp+grZB2BQD9o=";
  };

  nativeBuildInputs = [ inkscape xcursorgen ];
  
  installPhase = ''
    install -dm 0755 $out/share/icons
    cp -pr dist/volantes_cursors $out/share/icons
    cp -pr dist/volantes_light_cursors $out/share/icons
  '';
}
