# The knot: the one file that sees every truth (docs/wiring.md §3).
# `sources` is the flake's inputs today; swapping to npins is a one-line change
# here -- `(import ./npins) // args` -- and nothing below the root moves.
args@{ ... }:
let
  my = {
    sources = args;
    lib = import ./lib.nix { inherit my; };
    modules = import ./modules.nix { inherit my; };
    pkgs = import ./packages.nix { inherit my; };
  };
in
my
