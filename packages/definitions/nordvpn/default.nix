# NordVPN is not in nixpkgs (unfree binary, unstable download URLs). We vendor
# the official Debian package and autoPatchelf it onto NixOS.
#
# When 5.2.0 ages out of NordVPN's repo the fetchurl will 404 -> bump `version`
# and refresh `hash`. Available versions:
#   https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/n/nordvpn/
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  dpkg,
  # runtime libs the bundled binaries link against
  sqlite,
  libnl,
  libcap_ng,
  libidn2,
  # runtime tools the daemon shells out to (routing + killswitch)
  iproute2,
  iptables,
  nftables, # `nft` — firewall/killswitch rules
  libxslt, # `xsltproc` — generates the per-server OpenVPN config from a template
  procps,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nordvpn";
  version = "5.2.0";

  src = fetchurl {
    url = "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/n/nordvpn/nordvpn_${finalAttrs.version}_amd64.deb";
    hash = "sha256-mFBwH1iedC5NksQ+7h8hiCYt23H0DlRT06KteVA9uJs=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    dpkg
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    sqlite
    libnl
    libcap_ng
    libidn2
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/nordvpn $out/share

    # bundled shared libraries + helper binaries (norduserd, nordfileshare, openvpn)
    cp -r usr/lib/nordvpn/. $out/lib/nordvpn/

    # main binaries
    install -Dm755 usr/bin/nordvpn   $out/bin/nordvpn
    install -Dm755 usr/sbin/nordvpnd $out/bin/nordvpnd

    # data files (countries.dat, servers.dat, ovpn templates, ...)
    cp -r var/lib/nordvpn/. $out/share/

    # completions, icons, desktop entry, man page
    if [ -d usr/share ]; then
      cp -r usr/share/. $out/share/ || true
    fi

    runHook postInstall
  '';

  # The bundled .so files live in $out/lib/nordvpn and depend on each other, so
  # they must be on every binary's runpath.
  appendRunpaths = [ "${placeholder "out"}/lib/nordvpn" ];

  postFixup = ''
    wrapProgram $out/bin/nordvpnd \
      --prefix PATH : ${
        lib.makeBinPath [
          iproute2
          iptables
          nftables
          libxslt
          procps
        ]
      }
  '';

  meta = {
    description = "NordVPN CLI client (proprietary binary, autoPatchelf'd for NixOS)";
    homepage = "https://nordvpn.com";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "nordvpn";
  };
})
