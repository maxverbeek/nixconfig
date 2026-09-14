# modules/

Being restructured (2026-09-14, branch `redesign/flakeless`). The architecture
documents live in `docs/` at the repository root, which is gitignored
(`.git/info/exclude`), so they exist only in the main checkout
(`/home/max/nixconfig/docs/`), not in worktrees:

- `wiring.md`: the rules (what may wire, module classes, the closed namespace list).
- `structure.md`: the approved target layout and where every current file goes.
- `desired-state.md`: worked examples for each pattern.
- `migration-handoff.md`: status and open decisions.

During the restructure this directory holds two file shapes side by side,
split by shape between two loaders (`flake.nix` for flake-parts modules,
`modules.nix` for shards). Home-manager is gone and `roles/` is going: do not
add either. This file becomes the tracked summary of the new layout once the
restructure lands.
