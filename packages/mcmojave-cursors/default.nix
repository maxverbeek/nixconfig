{ stdenvNoCC, fetchFromGitHub, inkscape, xcursorgen }:

stdenvNoCC.mkDerivation rec {
  name = "mcmojave-cursors";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "McMojave-cursors";
    rev = "7d0bfc1f91028191cdc220b87fd335a235ee4439";
    sha256 = "sha256-4YqSucpxA7jsuJ9aADjJfKRPgPR89oq2l0T1N28+GV0=";
  };
  
  installPhase = ''
    install -dm 0755 $out/share/icons/McMojave-cursors
    cp -pr dist/. $out/share/icons/McMojave-cursors/
  '';
}
