{ config, lib, ... }:
let
  agentsDir = "${config.flake.lib.repoRoot}/modules/development/agents";
  pluginsDir = "${agentsDir}/_plugins";
  sharedDir = "${agentsDir}/_shared";

  marketplaces = {
    researchable-tools.source = {
      source = "git";
      url = "git@gitlab.com:researchable/general/claude-code-skills.git";
    };

    caveman.source = {
      source = "github";
      repo = "JuliusBrussee/caveman";
    };

    ponytail.source = {
      source = "github";
      repo = "DietrichGebert/ponytail";
    };
  };

  basePlugins = {
    "typescript-lsp@claude-plugins-official" = true;
    "gopls-lsp@claude-plugins-official" = true;
    "rust-analyzer-lsp@claude-plugins-official" = true;
    "gitlab@researchable-tools" = true;
    "k8s@researchable-tools" = true;
    "workflow@researchable-tools" = true;
    "freedcamp@researchable-tools" = false;
    "caveman@caveman" = false;
    "ponytail@ponytail" = true;
  };

  profiles = {
    claude = {
      plugins = [ "normal" ];
      superpowers = false;
    };
    claudes = {
      plugins = [ "normal" ];
      superpowers = true;
    };
    claudeh = {
      plugins = [ "hours" ];
      superpowers = false;
    };
  };
in
{
  flake.modules.homeManager.development =
    { pkgs, lib, config, ... }:
    let
      mkProfile =
        name:
        { plugins, superpowers }:
        let
          settings = builtins.toJSON {
            extraKnownMarketplaces = marketplaces;
            enabledPlugins = basePlugins // {
              "superpowers@claude-plugins-official" = superpowers;
            };
          };

          pluginFlags = lib.concatMapStringsSep " " (p: "--plugin-dir ${pluginsDir}/${p}") plugins;
        in
        pkgs.writeShellScriptBin name ''
          exec ${pkgs.claude-code}/bin/claude \
            --settings ${lib.escapeShellArg settings} \
            ${pluginFlags} \
            "$@"
        '';

      mkLiveLink = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      home.packages = lib.mapAttrsToList mkProfile profiles;

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
      };

      # Seed settings.json only if missing, then leave it alone forever.
      home.activation.claudeSettingsSeed = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -e "$HOME/.claude/settings.json" ]; then
          run install -Dm644 ${sharedDir}/settings.seed.json "$HOME/.claude/settings.json"
        fi
      '';
    };
}
