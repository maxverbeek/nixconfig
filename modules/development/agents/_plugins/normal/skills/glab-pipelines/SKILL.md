---
name: glab-pipelines
description: List recent GitLab CI pipelines for the current project. Accepts an optional ref (branch or tag name), defaults to the current branch.
argument-hint: [ref]
---

# Recent GitLab CI Pipelines

!`bash ${CLAUDE_SKILL_DIR}/fetch.sh $ARGUMENTS`

Display these pipelines as a table with columns: ID, Status, Ref, Created At, Web URL.
