# Shard: imported with no arguments, so the outer structure is a plain attrset
# and only the leaf is a module function (docs/wiring.md §4).
#
# This wrapper is max's login shell, so it reads $ZDOTDIR/.zshrc from the store
# and IGNORES ~/.zshrc -- every `programs.zsh.initContent` anywhere in
# home-manager stops taking effect once it is installed. Everything that used to
# arrive that way (fzf, zoxide, starship, dircolors, kubectl/op completions,
# osc7) therefore lives here instead.
{
  wrappers.config.zsh =
    {
      pkgs,
      lib,
      wlib,
      ...
    }:
    let
      checkdocker = pkgs.writeScript "checkdocker" ''
        #!${pkgs.bash}/bin/bash

        if [ "$(${pkgs.docker}/bin/docker ps -q | wc -l)" -gt 0 ]; then
          read -p "There are containers running, shutdown anyway? y/n: " -n 1 -r
          echo
          if [[ ! $REPLY =~ [Yy]$ ]]; then
            exit 1
          fi
        fi

        exit 0
      '';
    in
    {
      imports = [ wlib.wrapperModules.zsh ];

      package = pkgs.zsh;

      hmSessionVariables = null;

      env.FZF_DEFAULT_COMMAND = ''ag --ignore .git --hidden -g ""'';

      zshAliases = {
        zathura = "zathura --fork";
        shutdown = "${checkdocker} && shutdown now";
        open = "xdg-open";
        ll = "ls -al";
        la = "ls -a";
        ld = "ls";
        ks = "ls";
        gsm = "git sm";
        gsd = "git sd";
        gl = "git l";
        wtlm = "work ticket list --mine";
        wtlms = "work ticket list --mine --sprint";
        dc = "docker compose";
        ":q" = "exit";
        ":wq" = "exit";
      };

      # compinit must run before any shard's `compdef`, hence mkBefore. The rest
      # of the order here is ours to choose; other shards append with mkAfter.
      zshrc.content = lib.mkBefore ''
        eval "$(${pkgs.coreutils}/bin/dircolors -b)"

        autoload -U compinit && compinit

        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        ZSH_AUTOSUGGEST_STRATEGY=(history)

        # Replaces zsh-z: same frecency jumping, but moved/deleted directories are
        # pruned on first failed jump instead of lingering until their score
        # decays. --cmd z keeps the muscle memory (and adds `zi` = fzf picker).
        eval "$(${pkgs.zoxide}/bin/zoxide init zsh --cmd z)"

        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

        HISTSIZE="10000"
        SAVEHIST="10000"
        HISTFILE="$HOME/.zsh_history"
        mkdir -p "$(dirname "$HISTFILE")"

        for opt in \
          HIST_FCNTL_LOCK HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY autocd \
          NO_APPEND_HISTORY NO_EXTENDED_HISTORY NO_HIST_EXPIRE_DUPS_FIRST \
          NO_HIST_FIND_NO_DUPS NO_HIST_IGNORE_ALL_DUPS NO_HIST_SAVE_NO_DUPS
        do
          setopt "$opt"
        done
        unset opt

        if [[ $options[zle] = on ]]; then
          source <(${pkgs.fzf}/bin/fzf --zsh)
        fi

        # Guarded on the command existing: the same wrapper is the login shell on
        # the VPS, which has no kubectl/helm/op, and an unguarded
        # `source <(...)` prints an error on every login there.
        (( $+commands[kubectl] )) && source <(kubectl completion zsh)
        (( $+commands[helm] )) && source <(helm completion zsh)
        (( $+commands[helm] )) && source <(helm diff completion zsh)

        # Global alias: -oenv anywhere in a command becomes a kubectl
        # go-template flag rendering a secret's .data as sourceable dotenv
        # export lines. The -- is required for an alias name starting with -.
        alias -g -- -oenv="-o go-template='{{range \$k,\$v := .data}}export {{\$k}}={{\$v | base64decode}}{{\"\n\"}}{{end}}'"

        (( $+commands[op] )) && eval "$(op completion zsh)"

        # make it so that cd-ing in zsh will send escape sequences to the terminal emulator (foot) so that it is aware
        # from which cwd to spawn new terminals.
        function osc7-pwd() {
            emulate -L zsh # also sets localoptions for us
            setopt extendedglob
            local LC_ALL=C
            printf '\e]7;file://%s%s\e\' $HOST ''${PWD//(#m)([^@-Za-z&-;_~])/%''${(l:2::0:)$(([##16]#MATCH))}}
        }

        function chpwd-osc7-pwd() {
            (( ZSH_SUBSHELL )) || osc7-pwd
        }
        add-zsh-hook -Uz chpwd chpwd-osc7-pwd

        alias ls="ls --color=auto"

        # Pass bare [] ^ ~ through like bash instead of aborting the command
        # with "no matches found" (jq '.a[]' etc).
        unsetopt nomatch

        # Tab on a word that is a GLOBAL alias (-oenv etc) expands it in the
        # buffer, like !$ already does, before falling back to normal
        # completion. `regular false` keeps ordinary aliases (ll, dc, ...)
        # completing normally instead of exploding into their definitions --
        # note it gates ^Xa identically (same expand-alias-word context), so
        # nothing expands regular aliases any more.
        zstyle ':completion:*' completer _expand_alias _complete _ignored
        zstyle ':completion:expand-alias-word:*' regular false

        # Paste highlight: the default standout renders red in Kanagawa and
        # reads like an error; dim grey just marks "from the clipboard".
        zle_highlight=(paste:fg=8)

        # Esc latency: zsh's 400ms default plus the plugin's own timeout.
        KEYTIMEOUT=1
        ZVM_KEYTIMEOUT=0.05

        ZVM_SYSTEM_CLIPBOARD_ENABLED=true  # y/p hit the Wayland clipboard
        ZVM_LINE_INIT_MODE=i  # every prompt starts in insert mode (literal
                              # 'i': the plugin isn't sourced yet here)

        autoload -U edit-command-line up-line-or-beginning-search down-line-or-beginning-search
        zle -N edit-command-line
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search

        # zsh-vi-mode overwrites bindings made before it initialises, so all
        # vi-mode keys must live in this hook or they silently vanish.
        function zvm_after_init() {
          # `v` from normal mode, ^X^E (the bash chord) straight from insert
          # mode; ^V keeps its stock quoted-insert.
          bindkey -M vicmd v edit-command-line
          bindkey -M viins '^X^E' edit-command-line

          # History, three ways:
          #  - j/k and arrows walk it filtered by the typed prefix (the
          #    default is a move-within-line/history hybrid that behaves
          #    differently on wrapped vs single-line commands)
          #  - ^R / normal-mode `/` open the fzf picker (the vi search jumps
          #    blind to one match with no preview; `?` too -- forward search
          #    from the newest entry has nothing to find)
          bindkey -M vicmd k up-line-or-beginning-search
          bindkey -M vicmd j down-line-or-beginning-search
          bindkey -M vicmd '/' fzf-history-widget
          bindkey -M vicmd '?' fzf-history-widget
          for m in viins vicmd; do
            bindkey -M $m '^[[A' up-line-or-beginning-search
            bindkey -M $m '^[[B' down-line-or-beginning-search
            bindkey -M $m '^[OA' up-line-or-beginning-search
            bindkey -M $m '^[OB' down-line-or-beginning-search
            # fzf's own bindings are among what the plugin clobbers
            bindkey -M $m '^R' fzf-history-widget
            bindkey -M $m '^T' fzf-file-widget
          done

          # Accept the autosuggestion without reaching for the arrow key.
          bindkey -M viins '^ ' autosuggest-accept
          bindkey -M viins '^F' autosuggest-accept

          # Ctrl+/ (arrives as ^_): undo without leaving insert mode -- e.g.
          # a tab-expanded !$ back to literal. Esc-u does the same, vim-style.
          bindkey -M viins '^_' undo

          # Vim treats one insert session as one undo unit, so undo after
          # tabbing wipes the whole line, expansion and all. Breaking the
          # chain at each tab makes undo revert just the expansion.
          tab-split-undo() { zle split-undo; zle fzf-completion }
          zle -N tab-split-undo
          bindkey -M viins '^I' tab-split-undo
        }

        # The Claude Code statusline is NOT starship: it's the claude-statusline
        # package (modules/packages/_definitions/claude-statusline), wired up in
        # settings.json. Starship is only the shell prompt here.
        if [[ $TERM != "dumb" ]]; then
          eval "$(${pkgs.starship}/bin/starship init zsh)"
        fi

        # The wrapper owns this hook; NixOS's programs.direnv.enableZshIntegration
        # is off so /etc/zshrc does not add it a second time.
        eval "$(${pkgs.direnv}/bin/direnv hook zsh)"

        export GPG_TTY=$TTY
      '';
    };
}
