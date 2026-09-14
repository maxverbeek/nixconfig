# modules/

Being restructured (2026-09-14, branch `redesign/flakeless`). The architecture
documents live in `docs/` at the repository root, which is gitignored
(`.git/info/exclude`), so they exist only in the main checkout
(`/home/max/nixconfig/docs/`), not in worktrees:

- `wiring.md`: the rules (what may wire, module classes, the closed namespace list).
- `structure.md`: the approved target layout and where every current file goes.
- `desired-state.md`: worked examples for each pattern.
- `migration-handoff.md`: status and open decisions.

Every file here is a shard: an attrset keyed by module class, three levels
deep (`nixos.<namespace>.<name>`), loaded by `modules.nix` alone. A shard
never reads `my.sources` or flake inputs; wiring lives at the repository root.
Home-manager, flake-parts and `roles/` are gone: do not add any of them. This
file becomes the tracked summary of the new layout once the restructure lands.
