{ inputs, ... }:
{
  # niri window-activity collector: daemon (systemd user service), the `emit`
  # CLI, the global git post-commit hook, and the xtee/Claude hook scripts.
  # The `git mp`/`mpr` aliases in development/git.nix reference
  # niri-collector-report-mr from this module; the Claude UserPromptSubmit hook
  # in ~/.claude/settings.json references niri-collector-claude-prompt.
  flake.modules.homeManager.headful = {
    imports = [ inputs.niri-collector.homeModules.default ];

    services.niri-collector.enable = true;
  };
}
