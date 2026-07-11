#!/bin/sh
# Fetch GitLab CI pipeline job logs.
# Usage: fetch.sh [-C <repo-path>] <pipeline-id|latest|ref-name>
# -C <path>: resolve project from a different repo directory
# - Numeric argument: treated as a pipeline ID directly
# - "latest": resolves most recent pipeline for current branch
# - Anything else: treated as a ref (branch/tag), resolves its latest pipeline
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

ARG="${1:-latest}"

# Determine if arg is a pipeline ID (purely numeric) or a ref name
if echo "$ARG" | grep -qE '^[0-9]+$'; then
    PIPELINE_ID="$ARG"
    echo "Pipeline ID: $PIPELINE_ID"
else
    if [ "$ARG" = "latest" ]; then
      REF=$(git -C "$GIT_DIR" rev-parse --abbrev-ref HEAD)
    else
      REF="$ARG"
    fi
    PIPELINE_ID=$(glab api "projects/${ENCODED}/pipelines" -f ref="${REF}" -f per_page=1 -X GET 2>/dev/null | node -e "
      let d=''; process.stdin.on('data',c=>d+=c); process.stdin.on('end',()=>{
        const p=JSON.parse(d); if(p.length) console.log(p[0].id); else { console.error('No pipelines found for ref: ${REF}'); process.exit(1); }
      })")
    echo "Resolved latest pipeline for ref '$REF': $PIPELINE_ID"
fi

echo "Project: $PROJECT_PATH"
echo "Pipeline: $PIPELINE_ID"
echo "---"

JOBS=$(glab api "projects/${ENCODED}/pipelines/${PIPELINE_ID}/jobs" 2>&1)
echo "JOBS:"
echo "$JOBS" | node -e "
  let d=''; process.stdin.on('data',c=>d+=c); process.stdin.on('end',()=>{
    const jobs=JSON.parse(d);
    jobs.forEach(j => console.log(j.id + ' | ' + j.status.padEnd(8) + ' | ' + j.stage.padEnd(12) + ' | ' + j.name + ' | ' + (j.duration||0).toFixed(1) + 's'));
  })"
echo "---"

# Fetch traces for failed jobs, or all if none failed
FAILED_IDS=$(echo "$JOBS" | node -e "
  let d=''; process.stdin.on('data',c=>d+=c); process.stdin.on('end',()=>{
    const jobs=JSON.parse(d);
    const failed=jobs.filter(j=>j.status==='failed');
    const show=failed.length?failed:jobs;
    show.forEach(j=>console.log(j.id+' '+j.name));
  })")

echo "$FAILED_IDS" | while read -r JOB_ID JOB_NAME; do
  [ -z "$JOB_ID" ] && continue
  echo ""
  echo "=== JOB: $JOB_NAME (id: $JOB_ID) ==="
  glab api "projects/${ENCODED}/jobs/${JOB_ID}/trace" 2>&1 | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | sed -n '/step_script/,/section_end.*step_script/p' | head -200
done
