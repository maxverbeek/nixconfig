# The knot: the one file that sees every truth (docs/wiring.md §3).
# `sources` is the flake's inputs when flake.nix calls `import ./. inputs`, and
# falls back to flake.lock so `nix build -f . pkgs.wrapped.git` works without
# it. Only the plain source trees resolve that way; see lib/sources.nix.
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
