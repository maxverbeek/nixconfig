{ pkgs, ... }:

let
  checkdocker = pkgs.writeScript "checkdocker" ''
    #!/usr/bin/env bash

    if [ "$(${pkgs.docker}/bin/docker ps -q | wc -l)" -gt 0 ]; then
      read -p "There are containers running, shutdown anyway? y/n: " -n 1 -r
      echo
      if [[ ! $REPLY =~ [Yy]$ ]]; then
        exit 1
      fi
    fi

    exit 0
  '';
in {
  home.packages = with pkgs; [
    thefuck
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;

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
      dc = "docker-compose";
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

  };

  programs.starship = {
    enable = true;
  };

  programs.dircolors = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = ''ag --ignore .git --hidden -g ""'';
  };
}
