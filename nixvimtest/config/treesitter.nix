{
  plugins.treesitter = {
    enable = true;

    disabledLanguages = [
      "cpp"
      "cuda"
      "latex"
    ];

    incrementalSelection = {
      enable = true;
      keymaps = {
        initSelection = "gsi";
        scopeIncremental = "grc";
        nodeIncremental = "<M-h>";
        nodeDecremental = "<M-l>";
      };
    };
  };

  plugins.ts-autotag.enable = true;
  plugins.nvim-autopairs.enable = true;
}
