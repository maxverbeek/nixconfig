---
name: glab-pipelines
description: List recent GitLab CI pipelines for the current project. Accepts an optional ref (branch or tag name), defaults to the current branch.
---

# Recent GitLab CI Pipelines

Run `fetch.sh` from this skill directory, passing the requested ref when one was
provided. Run it from the repository being inspected; when that is not the
current working directory, pass `-C <repo-path>` first.

Display these pipelines as a table with columns: ID, Status, Ref, Created At, Web URL.
