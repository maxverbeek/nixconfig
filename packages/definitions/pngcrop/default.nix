{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "pngcrop";
  version = "v0.1.2";

  src = fetchFromGitHub {
    owner = "maxverbeek";
    repo = pname;
    rev = version;
    sha256 = "sha256-CcJru1z57hYfYKz4ewk10BO7/47T2UOBEcYmeq7Z4vI=";
  };

  cargoHash = "sha256-vFBVcd8BS24Q+okCxk/Pqr5fHQBR1OAOaPJL3RPaVO8=";

  meta = with lib; {
    description = "A tool to crop away background around edges of an image";
    homepage = "https://github.com/maxverbeek/pngcrop";
    license = licenses.unlicense;
  };
}
