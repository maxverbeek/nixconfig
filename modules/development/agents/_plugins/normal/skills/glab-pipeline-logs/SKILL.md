---
name: glab-pipeline-logs
description: Fetch and display GitLab CI job logs for a specific pipeline. Use when the user wants to read CI logs, debug pipeline failures, or check job output.
---

# GitLab CI Pipeline Logs

Run `fetch.sh` from this skill directory, passing the requested pipeline ID,
`latest`, or ref when one was provided. Run it from the repository being
inspected; when that is not the current working directory, pass `-C <repo-path>`
first.

Summarize the pipeline status. For failed jobs, analyze the error and suggest a fix. For successful jobs, just show the summary table.
