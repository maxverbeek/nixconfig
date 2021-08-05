{ pkgs, ... }:
pkgs.vimUtils.buildVimPluginFrom2Nix rec {
  pname = "nvim-ts-autotag";

  # latest commit as of 2021-07-05
  version = "99ba1f6d80842a4d82ff49fc0aa094fb9d199219";

  src = pkgs.fetchFromGitHub {
    owner = "windwp";
    repo = "nvim-ts-autotag";
    rev = version;
    sha256 = "sha256-NJHxsL7oF7ZRKOlFMpEdcWoBH+/21Pk0uy5ljmlHe4c=";
  };
}
