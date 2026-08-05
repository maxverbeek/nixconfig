{ config, ... }:
let
  agentsDir = "${config.flake.lib.repoRoot}/modules/development/agents";
  pluginsDir = "${agentsDir}/_plugins";
  sharedDir = "${agentsDir}/_shared";
in
{
  flake.modules.homeManager.development =
    { pkgs, lib, config, ... }:
    let
      mkClaude =
        name: plugins:
        let
          pluginFlags = lib.concatMapStringsSep " " (p: "--plugin-dir ${pluginsDir}/${p}") plugins;
        in
        pkgs.writeShellScriptBin name ''
          exec ${pkgs.claude-code}/bin/claude \
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

        ${pkgs.claude-code}/bin/claude \
          --settings "$overlay" \
          --plugin-dir ${pluginsDir}/normal \
          "$@"
      '';

      mkLiveLink = config.lib.file.mkOutOfStoreSymlink;
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
      home.packages = [
        claude
        claudeh
        claudes
      ];

      # Live symlinks into the repo: edit the source, no rebuild needed.
      #
      # settings.json is deliberately absent here. Claude Code writes to it at
      # runtime (/config, theme, plugin toggles) and a read-only /nix/store
      # symlink breaks that — and breaks the bwrap sandbox outright
      # (anthropics/claude-code#52525). It is seeded once by the activation
      # script below and then owned by Claude.
      home.file = {
        # AGENTS.md is the cross-agent source of truth. CLAUDE.md just imports
        # it, since Claude Code still does not read AGENTS.md natively
        # (anthropics/claude-code#6235).
        ".claude/AGENTS.md".source = mkLiveLink "${sharedDir}/AGENTS.md";
        ".claude/CLAUDE.md".text = "@AGENTS.md\n";
        ".claude/hooks".source = mkLiveLink "${sharedDir}/hooks";

        # opencode reads AGENTS.md natively.
        ".config/opencode/AGENTS.md".source = mkLiveLink "${sharedDir}/AGENTS.md";

        # Codex has no CLAUDE.md fallback; point it at the same file.
        ".codex/AGENTS.md".source = mkLiveLink "${sharedDir}/AGENTS.md";

        ".agents/skills/register-hours" = {
          source = mkLiveLink "${pluginsDir}/hours/skills/register-hours";
          force = true;
        };

      };

      # Seed settings.json only if missing, then leave it alone forever.
      home.activation.claudeSettingsSeed = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -e "$HOME/.claude/settings.json" ]; then
          run install -Dm644 ${sharedDir}/settings.seed.json "$HOME/.claude/settings.json"
        fi
      '';

      home.activation.codexHoursConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
          run install -m600 "$normalized" "$config"
        elif [ ! -e "$config" ]; then
          run install -Dm600 ${codexHoursInstructions} "$config"
        fi
      '';
    };
}
