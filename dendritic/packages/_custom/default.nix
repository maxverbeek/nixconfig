{
  pngcrop = ./pngcrop;
  fa-custom = ./fontawesome-custom;
  teg-font = ./teg-font;
  volantes-cursors = ./volantes-cursors;
  mcmojave-cursors = ./mcmojave-cursors;
  responsively-app = ./responsively-app;
  figma-linux = ./figma-linux;
  neovim-ayu = ./neovim-ayu;
  neovim-opener-desktop = ./neovim-opener-desktop;
  vim-pandoc-markdown-preview = ./vim-pandoc-markdown-preview;
  inherit (import ./vimPlugins) kanagawa-nvim dressing-nvim;
  nodePackages = import ./nodePackages;
  rubocop = import ./rubocop;
  samdump2 = import ./samdump2;
  kiro = ./kiro;
}
