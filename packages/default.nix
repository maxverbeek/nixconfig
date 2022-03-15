{
  pngcrop = ./pngcrop;
  fa-custom = ./fontawesome-custom;
  teg-font = ./teg-font;
  volantes-cursors = ./volantes-cursors;
  mcmojave-cursors = ./mcmojave-cursors;
  responsively-app = ./responsively-app;
  figma-linux = ./figma-linux;
  neovim-ayu = ./neovim-ayu;
  vim-pandoc-markdown-preview = ./vim-pandoc-markdown-preview;
  inherit (import ./vimPlugins) kanagawa-nvim dressing-nvim;
  nodePackages = import ./nodePackages;
}
