# These plugins are in unstable, but unstable plugins are broken currently. So
# build them with stable nixpkgs instead.
{
  nvim-cmp = { pkgs, ... }: pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-cmp";
    version = "2021-09-21";
    src = pkgs.fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "0a8ca50d9e96ae5b84e71146b5eb9d30baabc84a";
      sha256 = "1lbp45hbwzprfpzrhkws853dnv1ax63bqnzav04bl787kk5ryajn";
    };
    meta.homepage = "https://github.com/hrsh7th/nvim-cmp/";
  };

  cmp-nvim-lsp = { pkgs, ... }: pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "cmp-nvim-lsp";
    version = "2021-09-17";
    src = pkgs.fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp";
      rev = "246a41c55668d5f84afcd805ee73b6e419375ae0";
      sha256 = "0ybnrs31i61l6z02fjz65ankxccd5587pnky4lsczcz12kpj6s4n";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp/";
  };

  cmp-path = { pkgs, ... }: pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "cmp-path";
    version = "2021-09-11";
    src = pkgs.fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-path";
      rev = "0016221b6143fd6bf308667c249e9dbdee835ae2";
      sha256 = "03k43xavw17bbjzmkknp9z4m8jv9hn6wyvjwaj1gpyz0n21kn5bb";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-path/";
  };

  cmp-buffer = { pkgs, ... }: pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "cmp-buffer";
    version = "2021-09-02";
    src = pkgs.fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-buffer";
      rev = "5dde5430757696be4169ad409210cf5088554ed6";
      sha256 = "0fdywbv4b0z1kjnkx9vxzvc4cvjyp9mnyv4xi14zndwjgf1gmcwl";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-buffer/";
  };
}
