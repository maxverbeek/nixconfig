---
name: glab-pipeline-logs
description: Fetch and display GitLab CI job logs for a specific pipeline. Use when the user wants to read CI logs, debug pipeline failures, or check job output.
argument-hint: <pipeline-id|latest> [ref]
aliases:
  - glablogs
---

# GitLab CI Pipeline Logs

!`bash ${CLAUDE_SKILL_DIR}/fetch.sh $ARGUMENTS`

Summarize the pipeline status. For failed jobs, analyze the error and suggest a fix. For successful jobs, just show the summary table.
