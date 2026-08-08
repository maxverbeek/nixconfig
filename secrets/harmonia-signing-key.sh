#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash

set -euo pipefail

generate() {
  ssh root@scopecreep mkdir -p /var/secrets
  printf '%s' "$binary_cache_scopecreep_1_secret" |
    ssh root@scopecreep 'umask 077; cat > /var/secrets/harmonia-signing-key'
  echo "Uploaded harmonia signing key to scopecreep:/var/secrets/harmonia-signing-key"
  echo "Public key (paste into modules/services/cachix.nix): $binary_cache_scopecreep_1_public"
}

export -f generate
bws run -- bash -c generate
