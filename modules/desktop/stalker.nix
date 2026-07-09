{ inputs, ... }:
{
  # stalker activity collector: daemon (systemd user service), the `emit`
  # CLI, the global git post-commit hook, and the xtee/Claude hook scripts.
  # The `git mp`/`mpr` aliases in development/git.nix reference
  # stalker-report-mr from this module; the Claude UserPromptSubmit hook
  # in ~/.claude/settings.json references stalker-claude-prompt.
  flake.modules.homeManager.headful = {
    imports = [ inputs.stalker.homeModules.default ];

    services.stalker.enable = true;
  };
}
