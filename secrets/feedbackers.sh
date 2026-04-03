#!/usr/bin/env bash

set -euo pipefail

deploy() {
  tmpfile=$(mktemp)
  trap 'rm -f "$tmpfile"' EXIT

  cat > "$tmpfile" <<EOF
SLACK_BOT_TOKEN=${feedback_slack_bot_token}
SLACK_SIGNING_SECRET=${feedback_slack_signing_secret}
CLAUDE_CODE_OAUTH_TOKEN=${claude_code_oauth_token}
EOF

  ssh root@scopecreep mkdir -p /var/secrets
  scp "$tmpfile" root@scopecreep:/var/secrets/feedbackers.env
  ssh root@scopecreep chmod 600 /var/secrets/feedbackers.env
  echo "Uploaded feedbackers.env to scopecreep:/var/secrets/feedbackers.env"
}

export -f deploy
bws run -- bash -c deploy
