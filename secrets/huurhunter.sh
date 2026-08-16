#!/usr/bin/env bash

set -euo pipefail

deploy() {
  tmpfile=$(mktemp)
  trap 'rm -f "$tmpfile"' EXIT

  cat > "$tmpfile" <<EOF
TELEGRAM_BOT_TOKEN=${huurhunter_telegram_bot_token}
TELEGRAM_CHAT_ID=${huurhunter_telegram_chat_id}
EOF

  ssh root@scopecreep mkdir -p /var/secrets
  scp "$tmpfile" root@scopecreep:/var/secrets/huurhunter.env
  ssh root@scopecreep chmod 600 /var/secrets/huurhunter.env
  echo "Uploaded huurhunter.env to scopecreep:/var/secrets/huurhunter.env"
}

export -f deploy
secretspec run -P huurhunter -- bash -c deploy
