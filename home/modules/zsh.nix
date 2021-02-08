{ pkgs, ... }:

{
  home.packages = with pkgs; [
    thefuck
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;

    shellAliases = {
      zathura = "zathura --fork";
      shutdown = "shutdown now";
      open = "xdg-open";
      ll = "ls -al";
      la = "ls -a";
      ld = "ls";
      ks = "ls";
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

  programs.fzf.enableZshIntegration = true;
}
