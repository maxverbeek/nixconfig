# User-level instructions

Source of truth: `~/nixconfig/modules/development/agents/_shared/AGENTS.md`.
Symlinked live into `~/.claude/AGENTS.md` and `~/.config/opencode/AGENTS.md`,
so edits here take effect immediately — no rebuild.

## Environment

- NixOS (flake at `~/nixconfig`, flake-parts + import-tree). Home Manager
  for user config. Niri on Wayland.
- Shell: zsh. Editor: Neovim. Terminal: alacritty.
- There is no `/etc/nixos`. Everything lives in `~/nixconfig`.
- Rebuild with `just` targets in `~/nixconfig/Justfile`.

## Tooling defaults

- Nix first. Do not suggest `apt`, `brew`, `pacman`, or global `npm -g`.
  A missing tool means adding it to a module or using `nix shell nixpkgs#x`.
- Python: `uv` for venvs/lockfiles, `ruff` for lint+format.
- Version manager: `mise` for language runtimes when a project needs one.
- Lint: `shellcheck` for shell, `pymarkdown` for markdown.
- `llm` (simonw's CLI) is a separate tool from Claude Code — its templates
  are not Claude skills, don't conflate them.

## Working style

- Be terse. The user reads diffs; don't narrate them.
- Prefer editing existing files over creating new ones.
- No speculative comments. No "added for X" / "used by Y" annotations —
  those rot. Only comment when the *why* would surprise a future reader.
- No backwards-compat shims, no defensive validation past system
  boundaries, no half-finished implementations.
- Never leave a task partially done and report it as complete.

## Nix specifics

- Never edit files under `/nix/store` — they are read-only by design.
  If something there looks wrong, the fix belongs in `~/nixconfig`.
- `~/.claude/settings.json` is deliberately NOT Nix-managed; it is a real
  mutable file so `/config` and plugin toggles work. Nix seeds it once if
  absent. Don't convert it to a store symlink.
- Config that must stay live-editable uses `mkOutOfStoreSymlink` pointing
  back into `~/nixconfig`.
