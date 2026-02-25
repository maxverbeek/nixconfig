{ ... }:
{
  flake.modules.homeManager.agents =
    { pkgs, ... }:
    let
      codex = pkgs.writeShellScriptBin "codex" ''
        if [[ $PWD =~ "Researchable/legal-mike" ]]; then
          export OPENAI_API_KEY=$(<"$HOME/.openai_key_legalmike")
        else
          export OPENAI_API_KEY=$(<"$HOME/.openai_key")
        fi

        exec ${pkgs.unstable.codex}/bin/codex "$@"
      '';

      gemini = pkgs.writeShellScriptBin "gemini" ''
        export GEMINI_API_KEY=$(<"$HOME/.gemini_key")

        exec ${pkgs.unstable.gemini-cli}/bin/gemini
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

        if { [[ -z "$cmd" ]] || [[ "$cmd" == "chat" ]] || [[ "$cmd" == "complete" ]] || [[ "$cmd" == "prompt" ]]; } && [[ "$found_key" -eq 0 ]]; then
          exec ${pkgs.llm}/bin/llm "$cmd" --key $OPENAI_API_KEY "''${@:2}"
        else
          exec ${pkgs.llm}/bin/llm "$@"
        fi
      '';
    in
    {
      home.packages = [
        codex
        llm
        gemini
        pkgs.opencode
      ];
    };
}
