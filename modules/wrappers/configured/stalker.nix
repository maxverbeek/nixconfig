{
  wrappers.configured.zsh =
    { lib, ... }:
    {
      # `work ... **<Tab>` runs the CLI's own candidates through fzf; bare <Tab>
      # still uses the package's _work completer.
      #
      # fzf-completion dispatches on _fzf_complete_<cmd> and hands the function
      # the line as a STRING -- no $words/$CURRENT like a compdef completer
      # gets, hence the re-split and index arithmetic below.
      zshrc.content = lib.mkAfter ''
        _fzf_complete_work() {
          # $1 is the line with the trigger AND the word being completed
          # stripped; that word arrives separately in $prefix. Rebuild the argv
          # and ask for the last word -- the same clap dynamic protocol the
          # package's own compdef completer speaks, so the binary stays the only
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

  wrappers.configured.git =
    { my, ... }:
    {
      # The global post-commit hook that reports authored commits to the daemon.
      # stalker's NixOS module installs no git config of its own: this wrapper's
      # config never reaches /etc for it to merge with.
      settings.core.hooksPath = toString my.pkgs.stalker-git-hooks;
    };
}
