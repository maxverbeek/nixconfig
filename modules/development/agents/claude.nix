{ config, lib, ... }:
let
  pluginsDir = "${config.flake.lib.repoRoot}/modules/development/agents/_plugins";

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
    { pkgs, ... }:
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
    in
    {
      home.packages = lib.mapAttrsToList mkProfile profiles;
    };
}
