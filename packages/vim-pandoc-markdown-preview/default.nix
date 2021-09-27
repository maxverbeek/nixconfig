{ pkgs, lib, ... }:
pkgs.vimUtils.buildVimPluginFrom2Nix rec {
  pname = "vim-pandoc-markdown-preview";

  # latest commit as of 2021-09-28
  version = "975328c1da15f15f6fd9f0197725044b6a74de49";

  src = pkgs.fetchFromGitHub {
    owner = "conornewton";
    repo = "vim-pandoc-markdown-preview";
    rev = version;
    sha256 = "sha256-9FYRHzFh3Teuv5Vc2oWOTc9nZQgU0yct4ysoVK4/IXA=";
  };
}
