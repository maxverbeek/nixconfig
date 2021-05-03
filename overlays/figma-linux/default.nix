{ stdenv, appimageTools, fetchurl, glib, dbus-glib, gtk3, gtk3-x11, dbus_tools,
libdbusmenu-gtk2, sqlite, alsaLib, xorg,
 autoPatchelfHook, makeDesktopItem }:
stdenv.mkDerivation rec {
  pname = "figma-linux";
  version = "0.7.2";

  src = fetchurl {
    url = "https://github.com/Figma-Linux/figma-linux/releases/download/v${version}/figma-linux_${version}_linux_x86_64.AppImage";
    sha256 = "07wv3crijqayprg0frhr8lgpj7jrh83gbi9g2xzcdsq3jp81m3hr";
    name = "${pname}-${version}.AppImage";
  };

  appimgContents = appimageTools.extractType2 {
    name = "${pname}-${version}";
    inherit src;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    glib
    gtk3
    gtk3-x11
    dbus-glib
    libdbusmenu-gtk2
    sqlite
    alsaLib
    xorg.libxshmfence
  ];

  desktopEntry = makeDesktopItem {
    name = "Figma Linux";
    desktopName = "Figma";
    exec = "figma-linux";
    comment = "Unofficial desktop client for Figma";
    categories = "Graphics";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt
    cp -RT ${appimgContents} $out/opt/
    ln -s $out/opt/figma-linux $out/bin/figma-linux

    for size in 24 36 48 64 72 96 128 192 256 384 512; do
      mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps"
      cp -rf \
        "${appimgContents}/icons/''${size}x''${size}.png" \
        "$out/share/icons/hicolor/''${size}x''${size}/apps/figma-linux.png"
    done

    mkdir -p $out/share/icons/hicolor/scalable/apps
    cp -rf "${appimgContents}/icons/scalable.svg" "$out/share/icons/hicolor/scalable/apps/figma-linux.svg"

    runHook postInstall
  '';

}
