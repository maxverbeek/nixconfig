{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      cachePackages.stalker = inputs.stalker.packages.${system}.default;
    };

  # stalker activity collector: daemon (systemd user service), the `emit`
  # CLI, the global git post-commit hook, and the xtee/Claude hook scripts.
  # The `git mp`/`mpr` aliases in development/git.nix reference
  # stalker-report-mr from this module; the Claude UserPromptSubmit hook
  # in ~/.claude/settings.json references stalker-claude-prompt.
  flake.modules.homeManager.headful = {
    imports = [ inputs.stalker.homeModules.default ];

    services.stalker.enable = true;
    # zsh completion for the `work` CLI comes with the module (dynamic:
    # ticket refs, projects, cycles complete from the local mirror).

    # `work ... **<Tab>` runs those same candidates through fzf, for when the
    # list is a few hundred tickets and the plain menu is a wall to page
    # through. Bare <Tab> is untouched and still shows the normal menu.
    #
    # fzf-completion dispatches on _fzf_complete_<cmd> (its fallback is path
    # completion, useless for `work`), and hands the function the line as a
    # STRING -- no $words/$CURRENT like a compdef completer gets, hence the
    # re-split and index arithmetic below.
    #
    # One call, whatever the binary returns for that position. Note refs
    # complete in two stages, so `show **<Tab>` offers project prefixes and
    # `show ABL-**<Tab>` offers that project's ~280 tickets -- pick the
    # project first, then search. Flattening those stages for fzf meant
    # re-deriving the CLI's own logic in zsh, so it isn't done here.
    programs.zsh.initContent = ''
      _fzf_complete_work() {
        # $1 is the line with the trigger AND the word being completed
        # stripped; that word arrives separately in $prefix. Rebuild the argv
        # and ask for the last word -- the same clap dynamic protocol the
        # module's own compdef completer speaks, so the binary stays the only
        # thing that knows how to produce candidates.
        local -a words=(''${(z)1} "$prefix")
        # _fzf_complete appends `-q "$prefix"` AFTER our flags, so passing
        # -q "" here would lose. Blank $prefix instead, now that the argv
        # above has it: the binary already narrowed on it, and reusing it as a
        # fuzzy query scores it against every ref and title and scrambles the
        # order.
        local prefix=""
        # Candidates are "value:help"; only the first colon delimits (titles
        # contain their own), so tab-split once. -d'\t' or fzf splits on
        # whitespace and only matches the title's first word.
        _fzf_complete --reverse -d'\t' -- "$@" < <(
          _CLAP_IFS=$'\n' \
          _CLAP_COMPLETE_INDEX=$(( ''${#words[@]} - 1 )) \
          COMPLETE=zsh \
            work -- "''${words[@]}" 2>/dev/null | sed 's/:/\t/'
        )
      }
      _fzf_complete_work_post() { cut -f1 }
    '';
  };
}
