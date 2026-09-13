# Wires modules/ (docs/wiring.md §2, §4).
#
# During the migration only `modules/wrappers/` is in the shard shape; the rest
# of `modules/` is still flake-parts shaped and is walked by import-tree from
# flake.nix (which excludes modules/wrappers/ so the two loaders do not collide).
# When flake-parts goes, this walks all of `modules/`.
{ my }:
my.lib.modules.importSharded 3 ./modules/wrappers
