{
  plugins.lsp = {
    enable = true;

    keymaps = {
      silent = true;
      lspBuf = {
        "gd" = "definition";
        "gD" = "implementation";
        "gk" = "signature_help";
        "0gD" = "type_definition";
        "gr" = "references";
        "g-1" = "document_symbol";
        "ga" = "code_action";
        "K" = "hover";
        "<C-]>" = "declaration";
        "<leader>fm" = "format";
        "<leader>rn" = "rename";
      };
      diagnostic = {
        "g[" = "goto_prev";
        "g]" = "goto_next";
      };
    };

    servers = {
      rust-analyzer = {
        enable = true;
        installCargo = false;
        installRustc = false;
      };
      nil_ls.enable = true;
      gopls.enable = true;
      tailwindcss.enable = true;
      svelte.enable = true;
      pyright.enable = true;
      clangd.enable = true;
      texlab.enable = true;
      terraformls.enable = true;
      tsserver.enable = true;
      # hls.enable = true;
      # nixd.enable = true;
    };
  };

  plugins.cmp = {
    enable = true;
    settings.sources = [
      { name = "nvim_lsp"; }
      { name = "luasnip"; }
      { name = "buffer"; }
      { name = "path"; }
    ];
  };

  plugins.luasnip.enable = true;
  plugins.lspkind.enable = true;
}
