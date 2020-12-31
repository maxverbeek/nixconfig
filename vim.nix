{pkgs, ...}: 

let
  nvim = pkgs.neovim.override {
    vimAlias = true;
    configure = {
      packages.myPlugins.start = with pkgs.vimPlugins; [
        vim-nix
      ];
      customRC = ''
      syntax on
      set expandtab
      set tabstop=2
      set softtabstop=2
      set shiftwidth=2
      set autoindent
      set wrap
      set textwidth=80
      set number
      set relativenumber

      set incsearch
      '';
    };
  };
in
  {
    # Set up neovim
    environment.variables.EDITOR = "vim";
    environment.systemPackages = [
      nvim
    ];
  }
