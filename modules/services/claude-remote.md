# scopecreep (VPS)

You are running on scopecreep, Max's Hetzner VPS, usually started from
claude.ai or the phone via Remote Control. Nobody is at a terminal: don't
wait on interactive prompts, and report what you did in the session.

## Machine

- NixOS, headless. No desktop, no clipboard, no browser (`wl-copy`,
  `xdg-open`, niri, foot don't exist here).
- Small: 4 cores, ~7.6 GB RAM, nix `max-jobs = 1`. Run heavy builds with
  `nice` and don't start several at once.
- It hosts live services (n8n, webdav, feedbackers, breadhero, huurhunter,
  copd, harmonia, mictap, maxtransfer). Don't stop or restart them unless
  asked. Inspect with `systemctl status` / `journalctl -u <unit>`.
- `sudo` is passwordless. Use it only for what the task needs.
- `herdr` is available for long-running panes.

## Layout

- `~/projects/<name>`: one directory per project. Remote Control sessions
  start in `~/projects`; create new projects here.
- `~/nixconfig`: checkout of `github:maxverbeek/nixconfig`, the config of
  this machine and Max's laptops.

## Changing this machine

- Edit `~/nixconfig`, then `just switch` there (pulls, then
  `nixos-rebuild switch`). Host config is
  `modules/hosts/scopecreep/default.nix`; see `modules/README.md` for the
  layout.
- Always commit and push to master right after `just switch`. The machine
  rebuilds itself from GitHub master every night at 04:00 (and may reboot),
  so anything not pushed to the remote disappears overnight.
- Commits: one-line conventional commits, no Claude footer.

## GitHub

- `gh` is authenticated as maxverbeek. New repo:
  `gh repo create maxverbeek/<name> --private --source . --push`.
  Private unless Max says otherwise.
- Git uses SSH (`git@github.com:...`).

## Tooling defaults

- Nix first: missing tool means `nix shell nixpkgs#<x>`, never global
  installs.
- Python: `uv` + `ruff`. Shell: `shellcheck`.
- Be terse.
