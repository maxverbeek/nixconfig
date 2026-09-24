{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "gog";
  version = "0.41.0-unstable-2026-09-23";

  # Fork with template-respecting --markdown fixes, pending upstream PR.
  src = fetchFromGitHub {
    owner = "maxverbeek";
    repo = "gogcli";
    rev = "c6effb3e379d224f8a0aa2a525905a7e93f1f08a";
    hash = "sha256-+xmSvFzVIKScc/lZ8jutBJDEO9vyp76uSPfWwvZuMAo=";
  };

  vendorHash = "sha256-TgXyWIfWLAsl0GXaWHgMG+qJQIeTg324sHZrW56nRQA=";

  subPackages = [ "cmd/gog" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/openclaw/gogcli/internal/cmd.version=${version}"
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
