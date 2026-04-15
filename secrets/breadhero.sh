#!/usr/bin/env bash

set -euo pipefail

deploy() {
  tmptoken=$(mktemp)
  tmpsecret=$(mktemp)
  tmpapikey=$(mktemp)
  trap 'rm -f "$tmptoken" "$tmpsecret" "$tmpapikey"' EXIT

  echo -n "${breadhero_slack_bot_token}" > "$tmptoken"
  echo -n "${breadhero_slack_signing_secret}" > "$tmpsecret"
  echo -n "${breadhero_leaderboard_api_key}" > "$tmpapikey"

  ssh root@scopecreep mkdir -p /var/secrets
  scp "$tmptoken" root@scopecreep:/var/secrets/breadhero-slack-bot-token
  scp "$tmpsecret" root@scopecreep:/var/secrets/breadhero-slack-signing-secret
  scp "$tmpapikey" root@scopecreep:/var/secrets/breadhero-leaderboard-api-key
  ssh root@scopecreep chmod 600 /var/secrets/breadhero-slack-bot-token /var/secrets/breadhero-slack-signing-secret /var/secrets/breadhero-leaderboard-api-key
  echo "Uploaded breadhero secrets to scopecreep:/var/secrets/"
}

export -f deploy
bws run -- bash -c deploy
