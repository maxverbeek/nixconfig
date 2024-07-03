{
  pkgs,
  config,
  lib,
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

  options = {
    modules.zsh.enable = lib.mkEnableOption "Enable ZSH";
  };

  config = lib.mkIf config.modules.zsh.enable {
    home.packages = with pkgs; [
      thefuck
      secrand
      gitlabcivars
      jqd
    ];

    programs.zsh = {
      enable = true;
      enableCompletion = true;

      autosuggestion.enable = true;

      autocd = true;

      # do this before the other shell aliasses so that
      # this definition of ls is used recursively
      initExtraFirst = ''
        alias ls="ls --color=auto"
      '';

      shellAliases = {
        zathura = "zathura --fork";
        shutdown = "${checkdocker} && shutdown now";
        open = "xdg-open";
        ll = "ls -al";
        la = "ls -a";
        ld = "ls";
        ks = "ls";
        dc = "docker compose";
        ":q" = "exit";
        ":wq" = "exit";
        git = "noglob git"; # use gits own globbing because it's smarter
      };

      # Disable zplug for now as it is stupid slow
      # maybe use zinit/zplugin at some point?
      # zplug = {
      #   enable = true;
      #   plugins = [
      #     { name = "agkozak/zsh-z"; }
      #     { name = "plugins/thefuck"; tags = [ "from:oh-my-zsh" ]; }
      #   ];
      # };

      plugins = with pkgs; [
        {
          name = "zsh-z";
          src = "${zsh-z}/share/zsh-z";
        }
        {
          name = "zsh-bd";
          src = "${zsh-bd}/share/zsh-bd";
          file = "bd.zsh";
        }
      ];

      initExtra = ''
        autoload -U edit-command-line
        zle -N edit-command-line
        bindkey -M vicmd v edit-command-line
      '';
    };

    programs.starship = {
      enable = true;
      enableNushellIntegration = false;
    };

    programs.dircolors = {
      enable = true;
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = ''ag --ignore .git --hidden -g ""'';
    };
  };
}
