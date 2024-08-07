{
  stdenv,
  lib,
  appimageTools,
  fetchurl,
  makeWrapper,
  electron_13,

  alsaLib,
  dbus-glib,
  glib,
  gtk3,
  gtk3-x11,
  libdbusmenu-gtk2,
  sqlite,
  xorg,
}:

stdenv.mkDerivation rec {
  pname = "figma-linux";
  version = "0.9.3";

  src = fetchurl {
    url = "https://github.com/Figma-Linux/figma-linux/releases/download/v${version}/figma-linux_${version}_linux_x86_64.AppImage";
    sha256 = "sha256-2sMYqQL2sHI1moUkTsKKJGrs+uqO340ENOFVacpzn7s=";
    name = "${pname}-${version}.AppImage";
  };

  appimgContents = appimageTools.extractType2 {
    name = "${pname}-${version}";
    inherit src;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/${pname} $out/share/icons/hicolor/scalable/apps $out/share/applications
    cp -a ${appimgContents}/{locales,resources} $out/share/${pname}
    cp -a ${appimgContents}/usr/share/icons $out/share
    cp -a ${appimgContents}/icons/scalable.svg $out/share/icons/hicolor/scalable/apps/figma-linux.svg

    cp -a ${appimgContents}/figma-linux.desktop $out/share/applications/${pname}.desktop

    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'

    runHook postInstall
  '';

  libPath = lib.makeLibraryPath [
    stdenv.cc.cc
    alsaLib
    dbus-glib
    glib
    gtk3
    gtk3-x11
    libdbusmenu-gtk2
    sqlite
    xorg.libxshmfence
  ];

  postFixup = ''
    makeWrapper ${electron_13}/bin/electron $out/bin/${pname} \
      --add-flags $out/share/${pname}/resources/app.asar \
      --prefix LD_LIBRARY_PATH : "${libPath}"
  '';
}
