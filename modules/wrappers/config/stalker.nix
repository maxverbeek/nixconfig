# stalker's flake exports only a home-manager module; the two pieces below are
# what it injected into zsh and git. Delete this file when stalker exports them
# itself (a NixOS module, or the hooks dir as a package).
{
  wrappers.config.zsh =
    { my, lib, ... }:
    let
      stalker = my.sources.stalker.packages.x86_64-linux.default;
    in
    {
      # Dynamic completion for the `work` CLI. This is `COMPLETE=zsh work`'s
      # emitted wrapper (clap_complete 4.6) with ONE extra branch: a candidate
      # ending in `-` (a ticket-ref project prefix like `ABL-`) is completed
      # WITHOUT the trailing space, so the next tab continues with the numbers.
      # Regenerate against upstream when bumping clap_complete.
      zshrc.content = lib.mkAfter ''
        function _clap_dynamic_completer_work() {
            local _CLAP_COMPLETE_INDEX=$(expr $CURRENT - 1)
            local _CLAP_IFS=$'\n'

            local completions=("''${(@f)$( \
                _CLAP_IFS="$_CLAP_IFS" \
                _CLAP_COMPLETE_INDEX="$_CLAP_COMPLETE_INDEX" \
                COMPLETE="zsh" \
                ${stalker}/bin/work -- "''${words[@]}" 2>/dev/null \
            )}")

            if [[ -n $completions ]]; then
                local -a dirs=()
                local -a prefixes=()
                local -a other=()
                local completion
                for completion in $completions; do
                    local value="''${completion%%:*}"
                    if [[ "$value" == */ ]]; then
                        local dir_no_slash="''${value%/}"
                        if [[ "$completion" == *:* ]]; then
                            local desc="''${completion#*:}"
                            dirs+=("$dir_no_slash:$desc")
                        else
                            dirs+=("$dir_no_slash")
                        fi
                    elif [[ "$value" == *- ]]; then
                        prefixes+=("$completion")
                    else
                        other+=("$completion")
                    fi
                done
                [[ -n $dirs ]] && _describe -V 'values' dirs -S '/' -r '/'
                [[ -n $prefixes ]] && _describe -V 'values' prefixes -S ""
                [[ -n $other ]] && _describe -V 'values' other
            fi
        }

        compdef _clap_dynamic_completer_work work

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

  wrappers.config.git =
    { my, pkgs, ... }:
    let
      stalker = my.sources.stalker.packages.x86_64-linux.default;

      # Global post-commit hook: report the authored commit, then chain to the
      # repo's own hook (core.hooksPath OVERRIDES per-repo hooks, so repos using
      # husky etc. keep working). Runs the emit in the FOREGROUND: it is
      # sub-millisecond against a live or absent daemon, and staying in the
      # foreground keeps the process ancestry (git -> shell -> terminal) alive so
      # the collector can resolve the origin window. timeout(2s) guards the
      # pathological wedged-daemon case; the hook itself always exits 0.
      postCommit = pkgs.writeShellScript "stalker-post-commit" ''
        # Re-entry guard: this hook must NEVER wind up exec'ing itself (directly
        # or through any path indirection). Belt for the suspenders below.
        if [ -n "''${STALKER_POST_COMMIT:-}" ]; then
          exit 0
        fi
        export STALKER_POST_COMMIT=1
        ${pkgs.coreutils}/bin/timeout 2 ${stalker}/bin/stalker emit git-commit \
          --sha "$(git rev-parse HEAD)" \
          --repo "$(git rev-parse --show-toplevel)" \
          >/dev/null 2>&1 || true
        # Chain to the repo's OWN hook. NEVER resolve it via `--git-path
        # hooks/post-commit`: --git-path honors core.hooksPath, which points at
        # THIS script's directory — the naive version exec'd itself forever.
        # `--git-dir` ignores hooksPath, so this is the shadowed per-repo hook.
        repo_hook="$(git rev-parse --git-dir)/hooks/post-commit"
        if [ -x "$repo_hook" ] && ! [ "$repo_hook" -ef "$0" ]; then
          exec "$repo_hook" "$@"
        fi
        exit 0
      '';

      hooksDir = pkgs.linkFarm "stalker-git-hooks" [
        {
          name = "post-commit";
          path = postCommit;
        }
      ];
    in
    {
      settings.core.hooksPath = toString hooksDir;
    };
}
