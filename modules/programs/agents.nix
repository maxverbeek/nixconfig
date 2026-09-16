{
  nixos.programs.agents =
    { my, pkgs, ... }:
    let
      # Impure: symlinked into $HOME by absolute path, see claude.nix.
      agentsDir = "${my.meta.repoRoot}/modules/development/agents";
      pluginsDir = "${agentsDir}/_plugins";
      sharedDir = "${agentsDir}/_shared";

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

      codexHoursInstructions = pkgs.writeText "codex-hours-instructions.toml" ''
        developer_instructions = """
        When Max asks to register hours, draft a timesheet, or reconstruct a
        workday, read ${pluginsDir}/hours/skills/register-hours/SKILL.md in
        full and follow it as the authoritative workflow. Do not load or use
        that workflow for unrelated tasks.
        """
      '';
    in
    {
      systemd.user.tmpfiles.users.max.rules = [
        "L+ %h/.config/opencode/plugins/opencode-notify.ts - - - - ${my.pkgs.opencode-notify}/opencode-notify.ts"

        # opencode reads AGENTS.md natively.
        "L+ %h/.config/opencode/AGENTS.md - - - - ${sharedDir}/AGENTS.md"

        # Codex has no CLAUDE.md fallback; point it at the same file.
        "L+ %h/.codex/AGENTS.md - - - - ${sharedDir}/AGENTS.md"

        "L+ %h/.agents/skills/register-hours - - - - ${pluginsDir}/hours/skills/register-hours"
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

      # tmpfiles cannot express "normalise an existing file", hence a oneshot.
      systemd.user.services.codex-hours-config = {
        description = "Normalise ~/.codex/hours.config.toml";
        wantedBy = [ "default.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          config="$HOME/.codex/hours.config.toml"
          if [ -e "$config" ] && ! ${pkgs.coreutils}/bin/head -n 1 "$config" \
            | ${pkgs.gnugrep}/bin/grep -q '^developer_instructions[[:space:]]*='
          then
            normalized="$(${pkgs.coreutils}/bin/mktemp --tmpdir codex-hours-config.XXXXXX.toml)"
            trap '${pkgs.coreutils}/bin/rm -f "$normalized"' EXIT

            ${pkgs.coreutils}/bin/cat ${codexHoursInstructions} > "$normalized"
            ${pkgs.coreutils}/bin/printf '\n' >> "$normalized"
            ${pkgs.gawk}/bin/awk '
              BEGIN { skipping = 0; started = 0 }
              !skipping && /^developer_instructions[[:space:]]*=[[:space:]]*"""/ {
                skipping = 1
                next
              }
              skipping && /^[[:space:]]*"""[[:space:]]*$/ {
                skipping = 0
                next
              }
              !skipping && !started && /^[[:space:]]*$/ { next }
              !skipping { started = 1; print }
            ' "$config" >> "$normalized"
            ${pkgs.coreutils}/bin/install -m600 "$normalized" "$config"
          elif [ ! -e "$config" ]; then
            ${pkgs.coreutils}/bin/install -Dm600 ${codexHoursInstructions} "$config"
          fi
        '';
      };
    };
}
