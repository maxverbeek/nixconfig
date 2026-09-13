{
  stdenv,
  fetchgit,
  openssl,
  which,
  ...
}:
stdenv.mkDerivation rec {
  name = "samdump2-${version}";
  version = "3.0.0";

  src = fetchgit {
    url = "git://git.launchpad.net/ubuntu/+source/samdump2";
    rev = "applied/3.0.0-7";
    sha256 = "sha256-P97KkGOKaoZBLUq4CBD0OFVcNITqzpErrPhO76weCkU=";
  };

  installPhase = ''
    install -D -m 755 samdump2 -t $out/bin
    install -D -m 644 samdump2.1 -t $out/share/man/man1
  '';

  nativeBuildInputs = [ which ];
  buildInputs = [ openssl ];
}
