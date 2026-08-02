#!/usr/bin/env bash
# Claude Code hands the statusline a JSON blob on stdin on every render. That
# blob is the only place rate-limit state exists — nothing on disk carries it,
# and there's no API to ask. So the statusline is also where we capture it.
#
# This wraps whatever statusline you actually want: it reads stdin once, drops a
# copy where the bar can watch it, then replays it to the real command so the
# statusline keeps working unchanged.
#
# Wire it up in settings.json:
#   "statusLine": { "type": "command", "command": "~/.claude/hooks/usage-dump.sh '<your real command>'" }
set -uo pipefail

OUT="${XDG_RUNTIME_DIR:-/tmp}/claude-usage.json"

input=$(cat)

# Write in place, NOT via mktemp+mv. A rename gives OUT a new inode every
# render, and an inotify watch on the path keeps following the old, unlinked
# one — the bar reads the first payload and then never sees another. The
# payload is a single sub-pipe-buffer write, so a reader never catches a torn
# file in practice; the truncate-and-write below is what keeps the watch alive.
printf '%s' "$input" > "$OUT"

# Hand the payload to the real statusline, if one was given. Its output is the
# statusline, so it must be the only thing on stdout.
if [ "$#" -gt 0 ] && [ -n "$1" ]; then
    printf '%s' "$input" | eval "$1"
fi
