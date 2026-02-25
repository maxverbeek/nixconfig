{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  name = "mcmojave-cursors";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "maxverbeek";
    repo = "McMojave-cursors";
    rev = "3dc696d42acf945ed3f40a64fc9440912f303a99";
    sha256 = "sha256-lvt2ZqGbfzkpf5rtJ8WUk/gQkEDfHvodyozNB2agWb4=";
  };

  installPhase = ''
    install -dm 0755 $out/share/icons/McMojave-cursors
    cp -pr dist/. $out/share/icons/McMojave-cursors/
  '';
}
