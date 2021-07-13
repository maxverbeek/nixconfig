{ pkgs, ... }:

{
  home.packages = with pkgs; [
    thefuck
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;

    autocd = true;

    shellAliases = {
      zathura = "zathura --fork";
      shutdown = "shutdown now";
      open = "xdg-open";
      ll = "ls -al";
      la = "ls -a";
      ld = "ls";
      ks = "ls";
      dc = "docker-compose";
      ":q" = "exit";
      ":wq" = "exit";
    };

    zplug = {
      enable = true;
      plugins = [
        { name = "agkozak/zsh-z"; }
        { name = "plugins/thefuck"; tags = [ "from:oh-my-zsh" ]; }
      ];
    };

  };

  programs.starship = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = ''ag --ignore .git --hidden -g ""'';
  };
}
