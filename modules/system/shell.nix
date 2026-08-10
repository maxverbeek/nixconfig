{ ... }:
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      programs.zsh = {
        enable = true;
        enableCompletion = false;
      };

      environment.pathsToLink = [ "/share/zsh" ];
    };

  flake.modules.homeManager.base =
    { pkgs, ... }:
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

      secrand = pkgs.writeScriptBin "secrand" ''
        #!${pkgs.ruby}/bin/ruby
        require 'securerandom'

        puts SecureRandom.hex(if ARGV[0].nil? then 64 else ARGV[0].to_i end)
      '';

      gitlabcivars = pkgs.writeScriptBin "gitlabcivars" ''
        #!${pkgs.bash}/bin/bash

        if [ ! -f ~/.gitlab_pat ]; then
          echo "File ~/.gitlab_pat not found"
          exit 1
        fi

        GITLAB_TOKEN=$(cat ~/.gitlab_pat) ${pkgs.glab}/bin/glab variable export | ${pkgs.jq}/bin/jq -r ".[] | (.key + \"=\" + .value)"
      '';

      jqd = pkgs.writeScriptBin "jqd" ''
        #!${pkgs.bash}/bin/bash

        exec jq 'map_values(.| @base64d)'
      '';
    in
    {
      home.packages = [
        secrand
        gitlabcivars
        jqd
      ];

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        autocd = true;

        initContent = ''
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
        '';

        shellAliases = {
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

        plugins = [
          {
            name = "vi-mode";
            src = pkgs.unstable.zsh-vi-mode;
            file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
          }
        ];
      };

      # The Claude Code statusline is NOT starship: it's the claude-statusline
      # package (modules/packages/_definitions/claude-statusline), wired up in
      # settings.json. Starship is only the shell prompt here.
      programs.starship = {
        enable = true;
        enableNushellIntegration = false;
      };

      # Replaces zsh-z: same frecency jumping, but moved/deleted directories are
      # pruned on first failed jump instead of lingering until their score
      # decays. --cmd z keeps the muscle memory (and adds `zi` = fzf picker).
      programs.zoxide = {
        enable = true;
        options = [ "--cmd" "z" ];
      };

      programs.dircolors.enable = true;

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
        defaultCommand = ''ag --ignore .git --hidden -g ""'';
      };
    };
}
