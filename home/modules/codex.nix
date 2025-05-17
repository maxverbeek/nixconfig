{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.codex;
  codex = (
    pkgs.writeShellScriptBin "codex" ''
      if [[ $PWD =~ "Researchable/legal-mike" ]]; then
        export OPENAI_API_KEY=$(<"$HOME/.openai_key_legalmike")
      else
        export OPENAI_API_KEY=$(<"$HOME/.openai_key")
      fi

      exec ${pkgs.custom.nodePackages."@openai/codex"}/bin/codex "$@"
    ''
  );

in
{
  options.modules.codex = {
    enable = lib.mkEnableOption "Enable codex module";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ codex ];
  };
}
