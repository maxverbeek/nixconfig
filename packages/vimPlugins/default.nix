{
  kanagawa-nvim = import ./kanagawa-nvim.nix;

  dressing-nvim = { pkgs, ... }:
    pkgs.vimUtils.buildVimPluginFrom2Nix {
      pname = "cmp-buffer";
      version = "2022-03-14";
      src = pkgs.fetchFromGitHub {
        owner = "stevearc";
        repo = "dressing.nvim";
        rev = "6006de7279207ed24110557cbc74efb6f6e6d1b3";
        sha256 = "sha256-ckKI/AYIyNdmd/T/g0V+uxJMbecbH6gAbc3ZEre9cCo=";
      };
      meta.homepage = "https://github.com/stevearc/dressing.nvim";
    };
}
