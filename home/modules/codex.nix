{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.codex;
  codex = pkgs.writeShellScriptBin "codex" ''
    if [[ $PWD =~ "Researchable/legal-mike" ]]; then
      export OPENAI_API_KEY=$(<"$HOME/.openai_key_legalmike")
    else
      export OPENAI_API_KEY=$(<"$HOME/.openai_key")
    fi

    exec ${cfg.codexPackage}/bin/codex "$@"
  '';

  llm = pkgs.writeShellScriptBin "llm" ''
    if [[ $PWD =~ "Researchable/legal-mike" ]]; then
      export OPENAI_API_KEY=$(<"$HOME/.openai_key_legalmike")
    else
      export OPENAI_API_KEY=$(<"$HOME/.openai_key")
    fi

    cmd=""
    if [[ "$#" -gt 0 ]]; then
      cmd="$1"
    fi

    found_key=0
    for arg in "$@"; do
      if [[ "$arg" == --key || "$arg" == --key=* ]]; then
        found_key=1
        break
      fi
    done

    # Only inject --key if command is chat, complete, prompt (or empty), and --key is not present
    if { [[ -z "$cmd" ]] || [[ "$cmd" == "chat" ]] || [[ "$cmd" == "complete" ]] || [[ "$cmd" == "prompt" ]]; } && [[ "$found_key" -eq 0 ]]; then
      exec ${cfg.llmPackage}/bin/llm "$cmd" --key $OPENAI_API_KEY "''${@:2}"
    else
      exec ${cfg.llmPackage}/bin/llm "$@"
    fi
  '';

in
{
  options.modules.codex = {
    enable = lib.mkEnableOption "Enable codex module";

    llmPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.llm;
      description = "Package providing the 'llm' command line tool";
    };

    codexPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.custom.nodePackages."@openai/codex";
      description = "Package providing the 'codex' CLI";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      codex
      llm
    ];
  };
}
