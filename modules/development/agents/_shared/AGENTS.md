# User-level instructions

Source of truth: `~/nixconfig/modules/development/agents/_shared/AGENTS.md`.
Symlinked live into `~/.claude/AGENTS.md` and `~/.config/opencode/AGENTS.md`,
so edits here take effect immediately, no rebuild.

## Environment

- NixOS (`~/nixconfig`: a plain `default.nix` knot with a thin flake shim;
  sharded modules under `modules/<namespace>/<name>.nix`, see
  `modules/README.md`). No Home Manager: programs are nix-wrapper-modules
  wrappers (`my.pkgs.wrapped.*`) or plain NixOS options. Niri on Wayland.
- Shell: zsh. Editor: Neovim. Terminal: foot.
- There is no `/etc/nixos`. Everything lives in `~/nixconfig`.
- Rebuild with `just` targets in `~/nixconfig/Justfile`.

## Local checkouts

`~/Researchable` holds a clone of every active (non-archived, non-empty)
repo in the `researchable` GitLab group; look there before cloning.
If the GitLab path is `researchable/sport-data-valley/{mvp,sdv}/<repo>` it
lives at `~/Researchable/sdv/<repo>`, otherwise strip the leading
`researchable/` and use the rest as the path under `~/Researchable`. Repos
from other GitLab groups (e.g. `legal-mike/<repo>`) live at
`~/Researchable/<group>/<repo>`.

## Tooling defaults

- Nix first. Do not suggest `apt`, `brew`, `pacman`, or global `npm -g`.
  A missing tool means adding it to a module or using `nix shell nixpkgs#x`.
- Python: `uv` for venvs/lockfiles, `ruff` for lint+format.
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

## Waiting on things (listeners, polls, background builds)

- Long work and waits belong in the background (`run_in_background`);
  don't block the conversation on them. But first run the probe command
  once, quickly, and look at its real output before wrapping it in a loop. Never assume a format (e.g.
  `herdr pane read` is plain text, not JSON).
- The loop must exit on probe failure, not only on success: a failing
  `jq`/`grep` inside `until` spins forever silently.
- Match only output produced after you started. Pane/scrollback waits
  (`herdr pane wait-output`) match stale text from earlier runs; anchor
  on a unique marker you echo first, or on the new command line, and
  make sure the end condition can't match that command line itself.
- Don't pipe into `tail`/`head` when the exit status matters; it masks
  the real one.
- Never `pkill -f <pattern>` where the pattern also appears in your own
  command line; it kills your shell. Use the task ID or a PID.
- MRs in the gitlab.com/researchable group get an automatic review from
  `researchable-claude-reviewer`, which usually posts resolvable threads.
  Unresolved threads block merging (`detailed_merge_status:
  discussions_not_resolved`), even with auto-merge on and a green
  pipeline. When waiting on an MR, end the wait on new review threads
  too, not only on merge or pipeline status, and address them first.
- A pipeline started with `glab ci run` has source `api`, not `web`. Jobs
  gated on `web` or `schedule` can then land in `manual` instead. Treat
  `manual` as an end state in pipeline waits, or the loop never exits.

## Plane tickets

- Always use the `work ticket` CLI (manage-tickets skill). Never curl
  api.plane.so — raw curl caused duplicate issues and PAT misuse before.
- A ticket's "header" is the human zone of the description: the text above
  the `---` separator. Human-only — one short sentence in the user's own
  words, nothing agent-added. Agent content goes below, under
  **Context added by Claude**.
- Retrospective tickets (work already done) land in the current sprint with
  the project's completed state (in ABL that state is named "Merged").

## Nix specifics

- Never edit files under `/nix/store` — they are read-only by design.
  If something there looks wrong, the fix belongs in `~/nixconfig`.
- `~/.claude/settings.json` is deliberately NOT Nix-managed; it is a real
  mutable file so `/config` and plugin toggles work. Nix seeds it once if
  absent. Don't convert it to a store symlink.
- Config that must stay live-editable uses `mkOutOfStoreSymlink` pointing
  back into `~/nixconfig`.
