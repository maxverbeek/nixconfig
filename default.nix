# `sources` is the flake's inputs, or the plain source trees from flake.lock
# when imported bare (`nix build -f .`); see lib/sources.nix.
args@{ ... }:
let
  my = {
    sources = import ./lib/sources.nix { lockFile = ./flake.lock; } // args;
    meta = import ./meta.nix { inherit my; };
    lib = import ./lib.nix { inherit my; };
    modules = import ./modules.nix { inherit my; };
    pkgs = import ./packages.nix { inherit my; };
    hosts = import ./hosts.nix { inherit my; };
  };
in
my
