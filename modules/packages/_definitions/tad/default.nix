{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libGL,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  xorg,
}:

let
  version = "0.14.0";

  icon = fetchurl {
    url = "https://raw.githubusercontent.com/antonycourtney/tad/master/packages/tad-app/res/AppIcon1024.png";
    hash = "sha256-IdEl/gOoyPR1Pn4KlSZSLoxKnHhPbpoWnUKkvef2OaY=";
  };
in
stdenv.mkDerivation {
  pname = "tad";
  inherit version;

  src = fetchurl {
    url = "https://github.com/antonycourtney/tad/releases/download/v${version}/tad-${version}.tar.bz2";
    hash = "sha256-UNudSCMM2DEljXP6HaEn8QwryoNY4pWwH5dbnicOXBo=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libGL
    libxkbcommon
    mesa
    nspr
    nss
    pango
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "tad";
      desktopName = "Tad";
      comment = "Tabular data viewer";
      exec = "tad %F";
      icon = "tad";
      terminal = false;
      categories = [
        "Utility"
        "Development"
      ];
      mimeTypes = [
        "text/csv"
        "application/x-sqlite3"
        "application/vnd.apache.parquet"
      ];
    })
  ];

  sourceRoot = "tad-${version}";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/tad $out/bin

    cp -r . $out/lib/tad

    # Wrap the main binary; use ELECTRON_EXTRA_LAUNCH_ARGS instead of
    # --add-flags because tad has its own argument parser that rejects
    # unknown Chromium/Electron flags.
    makeWrapper $out/lib/tad/tad $out/bin/tad \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libGL ]}" \
      --set-default ELECTRON_EXTRA_LAUNCH_ARGS "\''${NIXOS_OZONE_WL:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}"

    # Install icon
    install -Dm644 ${icon} $out/share/icons/hicolor/1024x1024/apps/tad.png

    runHook postInstall
  '';

  meta = with lib; {
    description = "Desktop application for viewing and analyzing tabular data";
    homepage = "https://www.tadviewer.com";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "tad";
  };
}
