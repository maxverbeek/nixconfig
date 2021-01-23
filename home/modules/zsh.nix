{ pkgs, ... }:

{
  home.packages = with pkgs; [
    thefuck
    starship
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;

    shellAliases = {
      zathura = "zathura --fork";
      shutdown = "sudo shutdown now";
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

    initExtra = ''eval "$(starship init zsh)"'';
  };

  programs.fzf.enableZshIntegration = true;
}
