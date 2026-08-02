#!/usr/bin/env bash
# PreToolUse hook for Bash — refuses commands that glob over the nix store.
#
# A pattern like /nix/store/*/bin/foo expands against ~100k store paths. Zsh
# builds the whole match list before running anything, which pins a core and
# has repeatedly taken the interactive shell (and the session attached to it)
# down with exit 137/144.
#
# The fix is always the same: resolve the one path you want instead of asking
# the shell to enumerate every path you don't.
#
#   command -v foo                          -> a binary on PATH
#   nix eval --raw nixpkgs#pkg               -> a store path by name
#   readlink -f /run/current-system/sw/bin/x -> what a wrapper points at
#
# Exit 2 tells Claude Code to block the call and feed stderr back as the reason.

set -euo pipefail

input=$(cat)
command=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')

[ -z "$command" ] && exit 0

# A glob is only dangerous when there's a wildcard inside the store path. A
# literal /nix/store/<hash>-name path is exactly what we want people using.
if printf '%s' "$command" | grep -qE '/nix/store/[^/ ")'"'"']*\*'; then
  cat >&2 <<'EOF'
Blocked: this command globs over /nix/store.

The shell expands that against ~100k store paths before running anything,
which has killed this session more than once (exit 137/144).

Resolve the single path instead:
  command -v <binary>                        # a binary on PATH
  nix eval --raw nixpkgs#<pkg>               # a store path by package name
  readlink -f /run/current-system/sw/bin/<x> # what a wrapper points at
  ls /nix/store/<full-hash>-<name>/...       # a literal path is fine

If you genuinely need to search the store, use `nix path-info` or a
`find /nix/store -maxdepth 1 -name '<specific-prefix>*'` with a narrow
prefix — not a bare wildcard in the middle of a path.
EOF
  exit 2
fi

exit 0
