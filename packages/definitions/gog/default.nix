{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "gog";
  version = "0.37.0";

  src = fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "v${version}";
    hash = "sha256-UQa9Z7zv2IuH7GL1udNee2F+uB2BAZA5a0/2XtFcBWg=";
  };

  # nixpkgs go is 1.26.5; go.mod asks for the 1.26.6 patch release.
  # Patch-version bumps gate nothing in the language; relax it.
  postPatch = ''
    substituteInPlace go.mod --replace-fail "go 1.26.6" "go 1.26.5"
  '';

  vendorHash = "sha256-+Nbuwok3dY/82gUDKeGgrC0F1ZqXSW8IpV6Q1yzIPvo=";

  subPackages = [ "cmd/gog" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  # Tests hit the network / need credentials.
  doCheck = false;

  meta = {
    description = "Google Workspace CLI (Gmail, Calendar, Drive, Docs, Sheets)";
    homepage = "https://github.com/openclaw/gogcli";
    license = lib.licenses.mit;
    mainProgram = "gog";
  };
}
