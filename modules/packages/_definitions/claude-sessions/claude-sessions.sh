#!/usr/bin/env bash
set -euo pipefail

HISTORY="${HOME}/.claude/history.jsonl"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-sessions"

if [[ ! -f "$HISTORY" ]]; then
  echo "Error: Claude history not found at $HISTORY" >&2
  exit 1
fi

usage() {
  cat <<'EOF'
Usage: claude-sessions [OPTIONS]

List Claude Code sessions across all projects.

Options:
  -d, --day           Show sessions from today (default if no number given)
  -d, --days N        Show sessions from the last N days
  -w, --week          Show sessions from the current week (since Monday)
  -l, --last-week     Show sessions from last week (Mon-Sun)
  -a, --all           Show all sessions (default)
  -h, --help          Show this help message
EOF
}

filter="true"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -w|--week)
      monday=$(date -d "$(date -d 'last monday' +%Y-%m-%d 2>/dev/null || date -d 'monday -7 days' +%Y-%m-%d)" +%s 2>/dev/null)
      if [[ "$(date +%u)" == "1" ]]; then
        monday=$(date -d "today 00:00" +%s)
      fi
      filter=".timestamp >= (${monday} * 1000)"
      shift
      ;;
    -l|--last-week)
      if [[ "$(date +%u)" == "1" ]]; then
        this_monday=$(date -d "today 00:00" +%s)
      else
        this_monday=$(date -d "last monday 00:00" +%s)
      fi
      last_monday=$((this_monday - 7 * 86400))
      filter=".timestamp >= (${last_monday} * 1000) and .timestamp < (${this_monday} * 1000)"
      shift
      ;;
    -d|--day|--days)
      shift
      if [[ $# -gt 0 && "$1" =~ ^[0-9]+$ ]]; then
        days="$1"
        cutoff=$(date -d "${days} days ago" +%s)
        filter=".timestamp >= (${cutoff} * 1000)"
        shift
      else
        today=$(date -d "today 00:00" +%s)
        filter=".timestamp >= (${today} * 1000)"
      fi
      ;;
    -a|--all)
      filter="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

mkdir -p "$CACHE_DIR"

generate_title() {
  local session_id="$1"
  local prompt="$2"
  local cache_file="${CACHE_DIR}/${session_id}"

  if [[ -f "$cache_file" ]]; then
    cat "$cache_file"
    return
  fi

  local title
  title=$(claude -p --model haiku --no-session-persistence \
    "Generate a short title (max 6 words) summarizing this user prompt. Output ONLY the title, nothing else: ${prompt}" 2>/dev/null) || title="$prompt"

  echo "$title" > "$cache_file"
  echo "$title"
}

export CACHE_DIR
export -f generate_title

# Collect sessions as TSV: sessionId \t dow \t date \t time \t dir \t prompt
sessions=$(
  jq -r --arg home "$HOME" "
    select(${filter})
  " "$HISTORY" \
  | jq -rs --arg home "$HOME" '
    group_by(.sessionId)
    | map(sort_by(.timestamp) | {
        sessionId: (.[0].sessionId // "unknown"),
        timestamp: .[0].timestamp,
        display: (([.[] | .display | select(startswith("/") | not)] | first) // .[0].display),
        project: .[0].project
      })
    | sort_by(.timestamp)
    | reverse
    | .[]
    | (.timestamp / 1000 | localtime | strftime("%a")) as $dow
    | (.timestamp / 1000 | localtime | strftime("%Y-%m-%d")) as $date
    | (.timestamp / 1000 | localtime | strftime("%H:%M")) as $time
    | (.project | gsub("^" + $home + "/"; "~/") | gsub("^" + $home + "$"; "~")) as $dir
    | (.display | gsub("\n"; " ") | gsub("\t"; " ")) as $prompt
    | "\(.sessionId)\t\($dow)\t\($date)\t\($time)\t\($dir)\t\($prompt)"
  '
)

if [[ -z "$sessions" ]]; then
  echo "No sessions found."
  exit 0
fi

# Generate titles in parallel, writing results to temp files
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

i=0
while IFS=$'\t' read -r session_id dow date_str time_str dir prompt; do
  (
    title=$(generate_title "$session_id" "$prompt")
    title=$(echo "$title" | tr '\t\n' '  ' | cut -c1-60)
    echo -e "${dow}\t${date_str}\t${time_str}\t${dir}\t${title}"
  ) > "${tmpdir}/${i}" &
  i=$((i + 1))
done <<< "$sessions"

wait

{
  echo -e "DAY\tDATE\tTIME\tPROJECT\tTITLE"
  for ((j=0; j<i; j++)); do
    cat "${tmpdir}/${j}"
  done
} | column -t -s $'\t'
