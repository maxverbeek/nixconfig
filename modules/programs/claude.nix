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

        # Seed settings.json only if missing, then leave it alone forever.
        "C %h/.claude/settings.json 0644 - - - ${sharedDir}/settings.seed.json"
      ];
    };
}
