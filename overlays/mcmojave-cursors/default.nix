{ stdenvNoCC, fetchFromGitHub, inkscape, xcursorgen }:

stdenvNoCC.mkDerivation rec {
  name = "mcmojave-cursors";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "McMojave-cursors";
    rev = "master";
    sha256 = "sha256-qmITQ5e83SA8CSD3YcGI+swGnmJXfXEAN+ecxLDWRkQ=";
  };

  nativeBuildInputs = [ inkscape xcursorgen ];

  buildPhase = ''
    patchShebangs build.sh
    ./build.sh
  '';
  
  installPhase = ''
    install -dm 0755 $out/share/icons/McMojave-cursors
    cp -pr dist/. $out/share/icons/McMojave-cursors/
  '';
}
