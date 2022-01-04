{ pkgs, lib, ... }:
pkgs.vimUtils.buildVimPluginFrom2Nix rec {
  pname = "kanagawa.nvim";

  # latest commit as of 2022-01-04
  version = "6b2b37466c9702700aa47a364711222ddfabf6aa";

  src = pkgs.fetchFromGitHub {
    owner = "rebelot";
    repo = pname;
    rev = version;
    sha256 = "sha256-0WYfd5bl+rwT6ibHb7xPgi5UOaCvcjn0PNbG6UI5W6c=";
  };
}
