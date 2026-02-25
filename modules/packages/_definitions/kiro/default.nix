{
  lib,
  stdenv,
  callPackage,
  fetchurl,
  path,
  extraCommandLineArgs ? "",
  useVSCodeRipgrep ? stdenv.hostPlatform.isDarwin,
}:

let
  sources = {
    "x86_64-linux" = {
      url = "https://prod.download.desktop.kiro.dev/releases/202508110105--distro-linux-x64-tar-gz/202508110105-distro-linux-x64.tar.gz";
      hash = "sha256-4tPE85P9yGNG0xsjSZeDqXP/euf1fYn0ew/FpyPF1w8=";
    };
  };
  src =
    sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
(callPackage (path + "/pkgs/applications/editors/vscode/generic.nix") {
  inherit useVSCodeRipgrep;
  commandLineArgs = extraCommandLineArgs;
  updateScript = null;

  version = "202508110105";
  pname = "kiro";

  # VSCode version that Kiro is based on
  vscodeVersion = "1.94.0";

  executableName = "kiro";
  longName = "Kiro";
  shortName = "kiro";

  src = fetchurl src;

  sourceRoot = "Kiro";

  meta = with lib; {
    description = "Kiro code editor";
    longDescription = ''
      Kiro is a code editor based on VS Code.
    '';
    homepage = "https://kiro.dev";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
})

