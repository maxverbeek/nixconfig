{
  # stalker activity collector: daemon (systemd user service), the `emit` CLI
  # and the xtee/Claude hook scripts, all from the flake's NixOS module. The
  # `git mp`/`mpr` aliases in development/git.nix reference stalker-report-mr;
  # the Claude UserPromptSubmit hook in ~/.claude/settings.json references
  # stalker-claude-prompt.
  #
  # The module installs no git config -- the wrapped git's core.hooksPath is set
  # in modules/wrappers/configured/stalker.nix -- and the `work` zsh completer ships
  # inside the package, so compinit picks it up off fpath.
  nixos.programs.stalker =
    { my, ... }:
    {
      imports = [ my.modules.external.stalker ];

      cachePackages.stalker = my.pkgs.stalker;

      services.stalker.enable = true;
    };
}
