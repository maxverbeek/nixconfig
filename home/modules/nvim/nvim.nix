{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    vimAlias = true;

    vimdiffAlias = true;
    configure = {

    };
  };
}
