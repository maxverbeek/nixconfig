#!/bin/sh
# List recent GitLab CI pipelines for a ref.
# Usage: fetch.sh [-C <repo-path>] [ref]
set -e

GIT_DIR="."
while [ $# -gt 0 ]; do
  case "$1" in
    -C) GIT_DIR="$2"; shift 2 ;;
    *)  break ;;
  esac
done

PROJECT_PATH=$(git -C "$GIT_DIR" remote get-url origin | sed -E 's|.*gitlab\.com[:/]||;s|\.git$||')
ENCODED=$(echo "$PROJECT_PATH" | sed 's|/|%2F|g')
REF="${1:-$(git -C "$GIT_DIR" rev-parse --abbrev-ref HEAD)}"

echo "Project: $PROJECT_PATH"
echo "Ref: $REF"
echo "---"
glab api "projects/${ENCODED}/pipelines" -f ref="${REF}" -f per_page=10 -X GET 2>&1
