{

  keymaps =
    let
      nmap = key: action: {
        inherit key action;
        mode = "n";
      };
    in
    [
      (nmap "<C-p>" "<cmd>Telescope git_files<CR>")
      (nmap "<C-f>" "<cmd>Telescope live_grep<CR>")
      (nmap "<leader><Tab>" "<cmd>Telescope file_browser<CR>")
    ];
  plugins.telescope = {
    enable = true;

    extensions = {
      file_browser.enable = true;
      fzf-native = {
        enable = true;
        fuzzy = true;
        caseMode = "smart_case";
      };
    };

    extraOptions.defaults.mappings.i = {
      "<C-j>" = "move_selection_next";
      "<C-k>" = "move_selection_previous";
    };
  };
}
