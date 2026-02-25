{ ... }:
{
  flake.modules.nixos.shell =
    { pkgs, ... }:
    {
      programs.zsh = {
        enable = true;
        enableCompletion = false;
      };

      environment.pathsToLink = [ "/share/zsh" ];
      users.users.max.shell = pkgs.zsh;
    };

  flake.modules.homeManager.shell =
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
          autoload -U edit-command-line

          alias ls="ls --color=auto"

          zle -N edit-command-line
          bindkey -M vicmd v edit-command-line

          eval "$(op completion zsh)"
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
          dc = "docker compose";
          ":q" = "exit";
          ":wq" = "exit";
          git = "noglob git";
        };

        plugins = [
          {
            name = "zsh-z";
            src = "${pkgs.zsh-z}/share/zsh-z";
          }
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
      };

      programs.dircolors.enable = true;

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
        defaultCommand = ''ag --ignore .git --hidden -g ""'';
      };
    };
}
