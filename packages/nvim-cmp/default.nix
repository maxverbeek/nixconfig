{ pkgs, ... }:
# This plugin is in unstable, but unstable plugins are broken currently. So build it with stable nixpkgs instead.
pkgs.vimUtils.buildVimPluginFrom2Nix {
  pname = "nvim-cmp";
  version = "2021-09-21";
  src = fetchFromGitHub {
    owner = "hrsh7th";
    repo = "nvim-cmp";
    rev = "0a8ca50d9e96ae5b84e71146b5eb9d30baabc84a";
    sha256 = "1lbp45hbwzprfpzrhkws853dnv1ax63bqnzav04bl787kk5ryajn";
  };
  meta.homepage = "https://github.com/hrsh7th/nvim-cmp/";
}
