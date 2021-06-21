{ lib, fetchurl, appimageTools }:

let
  version = "0.15.0";
  src = fetchurl {
    url = "https://github.com/responsively-org/responsively-app/releases/download/v${version}/ResponsivelyApp-${version}.AppImage";
    sha256 = "sha256-/GUj2tjdAF6rfCwO49yhNPVjwOQazX5IX3BShcd5NYA=";
  };

in

appimageTools.wrapType2 {
  name = "responsively";
  src = src;
  extraInstallCommands = ''
    mkdir -p $out/share/applications
    echo "[Desktop Entry]
Encoding=UTF-8
Type=Application
Exec=responsively
Name=Responsively App
Version=${version}" > $out/share/applications/responsively.desktop
  '';
}
