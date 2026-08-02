#!/usr/bin/env bash
# Claude Code notification hook — sends a libnotify notification when Claude
# needs input and the terminal window is not focused (niri-aware).
#
# The focus check + notification is backgrounded so the hook returns
# immediately and doesn't block Claude Code.

set -euo pipefail

# Drain stdin so the hook doesn't hang
cat > /dev/null &

NOTIFY_SEND="notify-send"
NIRI_MSG="niri"
APP_NAME="Claude Code"
ICON="claude-code"

# ── Find our niri window BEFORE backgrounding ──────────────────────────
# Walk the process tree from our PID upward to find the niri window.
# Must be done now while we still have a valid parent chain.
OUR_WINDOW_ID=""
if command -v "$NIRI_MSG" &>/dev/null; then
  windows=$("$NIRI_MSG" msg --json windows 2>/dev/null) || windows=""
  if [[ -n "$windows" ]]; then
    current=$$
    while (( current > 1 )); do
      wid=$(echo "$windows" | jq -r --arg pid "$current" '.[] | select(.pid == ($pid | tonumber)) | .id' 2>/dev/null)
      if [[ -n "$wid" ]]; then
        OUR_WINDOW_ID="$wid"
        break
      fi
      ppid=$(awk '{print $4}' "/proc/$current/stat" 2>/dev/null) || break
      [[ "$ppid" =~ ^[0-9]+$ ]] || break
      (( ppid <= 1 )) && break
      current=$ppid
    done
  fi
fi

# ── Check focus ─────────────────────────────────────────────────────────
is_window_focused() {
  [[ -z "$OUR_WINDOW_ID" ]] && return 1
  local focused_id
  focused_id=$("$NIRI_MSG" msg --json focused-window 2>/dev/null | jq -r '.id' 2>/dev/null) || return 1
  [[ "$focused_id" == "$OUR_WINDOW_ID" ]]
}

# ── Main ────────────────────────────────────────────────────────────────

# Run everything in a backgrounded subshell so the hook returns immediately
(
  # Don't notify if window is focused
  if is_window_focused; then
    exit 0
  fi

  # Send notification with a "Show" action
  action=$("$NOTIFY_SEND" \
    --app-name="$APP_NAME" \
    --icon="$ICON" \
    --wait \
    --expire-time=5000 \
    --action=show=Show \
    "$APP_NAME" \
    "Needs your input") || true

  if [[ "$action" == "show" && -n "$OUR_WINDOW_ID" ]]; then
    "$NIRI_MSG" msg action focus-window --id "$OUR_WINDOW_ID" 2>/dev/null
  fi
) &
disown

exit 0
