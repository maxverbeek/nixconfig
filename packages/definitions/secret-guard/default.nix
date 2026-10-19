{
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "secret-guard";
  version = "0.1.0-unstable-2026-10-15";

  src = fetchFromGitHub {
    owner = "WSeubring";
    repo = "secret-guard";
    rev = "78d73e1fe8ee1e054e07a5347d17d68cf892deb8";
    hash = "sha256-G2lmO0mmEQcLHbJJVyXBu3yPMmhmY3xj8CGSDWj8+3o=";
  };

  cargoHash = "sha256-OIo9HDzug76u6n2naft4Yn2BF2jotqKHmy45EOC6hTU=";

  # Upstream's crt-static also hits build scripts, which fails against nix glibc.
  postPatch = "rm .cargo/config.toml";

  meta.mainProgram = "secret-guard";
}
