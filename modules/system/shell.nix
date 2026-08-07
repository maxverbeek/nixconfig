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

      programs.starship = {
        enable = true;
        enableNushellIntegration = false;

        # Starship doubles as the Claude Code statusline via
        # `starship statusline claude-code`, which reads the same JSON blob
        # Claude hands its statusline command. It covers context, model and
        # directory out of the box; the one thing it has no module for is rate
        # limits, hence the custom quota segment.
        settings = {
          # tokens (ctx%) · model · dir+branch · 5h% weekly% · cost. Colour
          # separates the segments instead of divider characters. Braces are
          # required around a custom module: a bare "$custom.quota" parses as
          # $custom followed by the literal ".quota".
          profiles.claude = "$claude_context$claude_model$directory$git_branch\${custom.quota}";

          custom.quota = {
            command = "$HOME/.claude/hooks/claude-quota.sh";
            # No wrapping style: the script emits its own SGR codes so the cost
            # can be red or green independently of the percentages.
            format = "[$output]($style)";
            style = "bold purple";
            when = true;
          };

          claude_context = {
            # Absolute token count, not just a gauge. Parens must be escaped;
            # bare ones read as a format group.
            format = "[$input_tokens \\($percentage\\)]($style) ";
            symbol = "";
          };

          claude_model = {
            # No robot icon, and the technical name rather than the marketing
            # one. $model is the display_name, so the aliases below rewrite it —
            # there is no $id variable to use instead.
            format = "[$model]($style) ";
            symbol = "";
            style = "bold blue";
            model_aliases = {
              "Opus 5 (1M context)" = "opus-5[1m]";
              "Opus 5" = "opus-5";
              "Fable 5 (1M context)" = "fable-5[1m]";
              "Fable 5" = "fable-5";
              "Sonnet 5 (1M context)" = "sonnet-5[1m]";
              "Sonnet 5" = "sonnet-5";
              "Haiku 4.5" = "haiku-4.5";
            };
          };

          # The prompt's default "$all" includes $custom, which would run the
          # quota script on every shell prompt. There is no way to gate it: a
          # custom module sees an identical environment in both, `disabled` also
          # hides it from the claude profile, and any freshness check on the dump
          # is true in a live session for both. So spell out $all minus $custom.
          format = "$username$hostname$localip$shlvl$singularity$kubernetes$nats$directory$vcsh$fossil_branch$fossil_metrics$git_branch$git_commit$git_state$git_metrics$git_status$hg_branch$hg_state$pijul_channel$docker_context$package$bun$c$cmake$cobol$cpp$daml$dart$deno$dotnet$elixir$elm$erlang$fennel$fortran$gleam$golang$gradle$haskell$haxe$helm$java$julia$kotlin$lua$maven$mojo$nim$nodejs$ocaml$odin$opa$perl$php$pulumi$purescript$python$quarto$raku$rlang$red$ruby$rust$scala$solidity$swift$terraform$typst$vlang$vagrant$xmake$zig$buf$guix_shell$nix_shell$conda$pixi$meson$spack$memory_usage$aws$gcloud$openstack$azure$direnv$env_var$mise$crystal$sudo$cmd_duration$line_break$jobs$battery$time$status$container$netns$os$shell$character";

          # Visible from the start rather than hidden until 30%, and the colour
          # is what marks the segment as context.
          #
          # Thresholds are PERCENTAGES, not token counts — a threshold of 100000
          # silently never matches. These are 100k yellow and 400k red on the 1M
          # window; on a 200k model the same percentages land at 20k/80k, which
          # is proportionally the same warning and about right either way.
          claude_context.display = [
            {
              threshold = 0.0;
              style = "bold green";
            }
            {
              threshold = 10.0;
              style = "bold yellow";
            }
            {
              threshold = 40.0;
              style = "bold red";
            }
          ];
        };
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
