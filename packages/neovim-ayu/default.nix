{ pkgs, ... }:
pkgs.vimUtils.buildVimPluginFrom2Nix rec {
  pname = "neovim-ayu";

  # latest commit as of 2021-07-05
  version = "83f902098e0532d29792b5aa94b5652f85c53bbd";

  src = pkgs.fetchFromGitHub {
    owner = "Shatur";
    repo = "neovim-ayu";
    rev = version;
    sha256 = "sha256-MLOgtQ1SZidKiSOgQkN/fu5umdnWIQs6+92HpMZUuv4=";
  };
}
