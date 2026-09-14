{
  # opencode and claude-code used to arrive here via nixpkgs.overlays; they are
  # wired once in packages.nix's fromInputs now (docs/structure.md rule 6).
  nixos.programs.agents =
    { my, pkgs, ... }:
    let
      mkCodex =
        name: profileArgs:
        pkgs.writeShellScriptBin name ''
          if [[ $PWD =~ "Researchable/legal-mike" ]]; then
            export OPENAI_API_KEY=$(<"$HOME/.openai_key_legalmike")
          else
            export OPENAI_API_KEY=$(<"$HOME/.openai_key")
          fi

          exec ${my.pkgs.unstable.codex}/bin/codex ${profileArgs} "$@"
        '';

      codex = mkCodex "codex" "";
      codexh = mkCodex "codexh" "--profile hours";

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
      systemd.user.tmpfiles.users.max.rules = [
        "L+ %h/.config/opencode/plugins/opencode-notify.ts - - - - ${my.pkgs.opencode-notify}/opencode-notify.ts"
      ];

      environment.systemPackages = [
        codex
        codexh
        llm

        my.pkgs.opencode
        pkgs.mcp-grafana
        pkgs.libnotify
        my.pkgs.opencode-sessions
        my.pkgs.claude-sessions
        my.pkgs.wrapped.herdr
      ];
    };
}
