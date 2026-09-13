#!/usr/bin/env bash
set -euo pipefail

DB="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/opencode.db"

if [[ ! -f "$DB" ]]; then
  echo "Error: opencode database not found at $DB" >&2
  exit 1
fi

usage() {
  cat <<'EOF'
Usage: opencode-sessions [OPTIONS]

List opencode sessions across all projects.

Options:
  -d, --day           Show sessions from today (default if no number given)
  -d, --days N        Show sessions from the last N days
  -w, --week          Show sessions from the current week (since Monday)
  -l, --last-week     Show sessions from last week (Mon-Sun)
  -a, --all           Show all sessions (default)
  -s, --subagents     Show subagent sessions (hidden by default)
  -h, --help          Show this help message
EOF
}

where_clause="1=1"
show_subagents=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -w|--week)
      where_clause="s.time_created / 1000 >= unixepoch('now', 'localtime', 'weekday 1', '-7 days', 'start of day', 'utc')"
      shift
      ;;
    -l|--last-week)
      where_clause="s.time_created / 1000 >= unixepoch('now', 'localtime', 'weekday 1', '-14 days', 'start of day', 'utc') AND s.time_created / 1000 < unixepoch('now', 'localtime', 'weekday 1', '-7 days', 'start of day', 'utc')"
      shift
      ;;
    -d|--day|--days)
      shift
      if [[ $# -gt 0 && "$1" =~ ^[0-9]+$ ]]; then
        days="$1"
        where_clause="s.time_created / 1000 >= unixepoch('now', '-${days} days')"
        shift
      else
        where_clause="s.time_created / 1000 >= unixepoch('now', 'localtime', 'start of day', 'utc')"
      fi
      ;;
    -a|--all)
      where_clause="1=1"
      shift
      ;;
    -s|--subagents)
      show_subagents=true
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

subagent_filter=""
if [[ "$show_subagents" == false ]]; then
  subagent_filter="AND s.title NOT LIKE '%subagent)%'"
fi

sqlite3 -header -column "$DB" "
SELECT
  CASE strftime('%w', s.time_created / 1000, 'unixepoch', 'localtime')
    WHEN '0' THEN 'Sun' WHEN '1' THEN 'Mon' WHEN '2' THEN 'Tue'
    WHEN '3' THEN 'Wed' WHEN '4' THEN 'Thu' WHEN '5' THEN 'Fri' WHEN '6' THEN 'Sat'
  END AS dow,
  date(s.time_created / 1000, 'unixepoch', 'localtime') AS date,
  substr(time(s.time_created / 1000, 'unixepoch', 'localtime'), 1, 5) AS time,
  CASE p.worktree WHEN '/' THEN '~' ELSE REPLACE(p.worktree, '$HOME/', '~/') END AS directory,
  s.title
FROM session s
JOIN project p ON s.project_id = p.id
WHERE ${where_clause}
${subagent_filter}
ORDER BY s.time_created DESC;
"
