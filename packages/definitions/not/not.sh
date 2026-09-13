#!/usr/bin/env bash
set -euo pipefail

# not — send a desktop notification when a long-running command finishes.
# Usage: <long-running-command>; not
#        <long-running-command>; not "custom message"

get_message_from_history() {
  local histfile=""
  for f in "$HOME/.zsh_history" "$HOME/.histfile" "$HOME/.bash_history"; do
    if [[ -f "$f" ]]; then
      histfile="$f"
      break
    fi
  done

  if [[ -z "$histfile" ]]; then
    return 1
  fi

  local last_line
  last_line=$(tail -1 "$histfile")

  # Strip zsh extended history prefix: ": 1234567890:0;command"
  last_line="${last_line#: [0-9]*:*;}"
  # More robust: use regex
  if [[ "$last_line" =~ ^:[[:space:]][0-9]+:[0-9]+\;(.*)$ ]]; then
    last_line="${BASH_REMATCH[1]}"
  fi

  # Strip trailing "; not..." or "&& not..." or "| not..."
  last_line=$(echo "$last_line" | sed -E 's/[;&|]+[[:space:]]*not([[:space:]].*)?$//')

  # Trim whitespace
  last_line=$(echo "$last_line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  if [[ -n "$last_line" ]]; then
    echo "$last_line"
    return 0
  fi
  return 1
}

# Determine the notification message
if [[ $# -gt 0 ]]; then
  message="$*"
else
  message=$(get_message_from_history) || message="Command completed"
fi

# Find niri window ID by walking the PID ancestry tree
find_window_id() {
  local current="$PPID"
  local ancestors=()

  # Collect ancestor PIDs by walking /proc/PID/stat
  while [[ "$current" -gt 1 ]]; do
    ancestors+=("$current")
    local stat
    stat=$(< "/proc/$current/stat") || break
    # comm field can contain spaces/parens, so find last ')' first
    local rest
    rest="${stat##*) }"
    # PPID is the 2nd field after the comm block (fields: state ppid ...)
    local ppid
    ppid=$(echo "$rest" | awk '{print $2}')
    if [[ -z "$ppid" || "$ppid" -le 1 ]]; then
      break
    fi
    current="$ppid"
  done

  # Get niri windows and match against ancestor PIDs
  local windows
  windows=$(niri msg --json windows 2>/dev/null) || return 1

  for pid in "${ancestors[@]}"; do
    local wid
    wid=$(echo "$windows" | jq -r ".[] | select(.pid == $pid) | .id" 2>/dev/null)
    if [[ -n "$wid" ]]; then
      echo "$wid"
      return 0
    fi
  done

  return 1
}

window_id=$(find_window_id) || window_id=""

# Build notification arguments
notify_args=(
  --wait
  --app-name=not
  --icon=terminal
  --expire-time=30000
)

if [[ -n "$window_id" ]]; then
  notify_args+=(--action=show=Show)
fi

notify_args+=("Command completed" "$message")

# Send notification and handle action
result=$(notify-send "${notify_args[@]}") || true

if [[ "$result" == "show" && -n "$window_id" ]]; then
  niri msg action focus-window --id "$window_id"
fi
