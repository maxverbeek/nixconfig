{
  nixos.programs.claude =
    {
      my,
      pkgs,
      lib,
      ...
    }:
    let
      # Impure sources: the running system symlinks these into ~/.claude by
      # absolute path, so moving the directory dangles the links until the
      # next rebuild.
      agentsDir = "${my.meta.repoRoot}/modules/development/agents";
      pluginsDir = "${agentsDir}/_plugins";
      sharedDir = "${agentsDir}/_shared";

      mkClaude =
        name: plugins:
        let
          pluginFlags = lib.concatMapStringsSep " " (p: "--plugin-dir ${pluginsDir}/${p}") plugins;
        in
        pkgs.writeShellScriptBin name ''
          exec ${my.pkgs.claude-code}/bin/claude \
            ${pluginFlags} \
            "$@"
        '';

      claude = mkClaude "claude" [ "normal" ];
      claudeh = mkClaude "claudeh" [
        "normal"
        "hours"
      ];
      claudes = pkgs.writeShellScriptBin "claudes" ''
        settings="$HOME/.claude/settings.json"
        overlay="$(${pkgs.coreutils}/bin/mktemp --tmpdir claude-superpowers-settings.XXXXXX.json)"
        trap '${pkgs.coreutils}/bin/rm -f "$overlay"' EXIT

        if [[ -e "$settings" ]]; then
          if ! ${pkgs.jq}/bin/jq -ce \
            '{enabledPlugins: ((.enabledPlugins // {}) + {"superpowers@claude-plugins-official": true})}' \
            "$settings" > "$overlay"
          then
            echo "claudes: failed to read $settings" >&2
            exit 1
          fi
        else
          ${pkgs.coreutils}/bin/printf '%s\n' \
            '{"enabledPlugins":{"superpowers@claude-plugins-official":true}}' \
            > "$overlay"
        fi

        ${my.pkgs.claude-code}/bin/claude \
          --settings "$overlay" \
          --plugin-dir ${pluginsDir}/normal \
          "$@"
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
      environment.systemPackages = [
        claude
        claudeh
        claudes
        my.pkgs.claude-statusline
      ];

      systemd.user.tmpfiles.users.max.rules = [
        # Live symlinks into the repo: edit the source, no rebuild needed.
        # L+ replaces whatever is there at every login, so these stay ours.
        #
        # settings.json is deliberately absent: Claude Code writes to it at
        # runtime, and a read-only store symlink breaks that and the bwrap
        # sandbox outright (anthropics/claude-code#52525). The C rule below
        # seeds it once and Claude owns it after.

        # CLAUDE.md only imports AGENTS.md: Claude Code still does not read
        # AGENTS.md natively (anthropics/claude-code#6235).
        "L+ %h/.claude/AGENTS.md - - - - ${sharedDir}/AGENTS.md"
        "L+ %h/.claude/CLAUDE.md - - - - ${pkgs.writeText "CLAUDE.md" "@AGENTS.md\n"}"
        "L+ %h/.claude/hooks - - - - ${sharedDir}/hooks"

        # opencode reads AGENTS.md natively.
        "L+ %h/.config/opencode/AGENTS.md - - - - ${sharedDir}/AGENTS.md"

        # Codex has no CLAUDE.md fallback; point it at the same file.
        "L+ %h/.codex/AGENTS.md - - - - ${sharedDir}/AGENTS.md"

        "L+ %h/.agents/skills/register-hours - - - - ${pluginsDir}/hours/skills/register-hours"

        # Seed settings.json only if missing, then leave it alone forever.
        "C %h/.claude/settings.json 0644 - - - ${sharedDir}/settings.seed.json"
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
