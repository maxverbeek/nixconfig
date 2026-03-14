#!/usr/bin/env nix-shell
#!nix-shell -i bash -p apacheHttpd

set -euo pipefail

generate() {
  tmpfile=$(mktemp)
  trap 'rm -f "$tmpfile"' EXIT

  htpasswd -Bbc "$tmpfile" "$webdav_username" "$webdav_password"

  ssh root@scopecreep mkdir -p /run/secrets
  scp "$tmpfile" root@scopecreep:/run/secrets/webdav.htpasswd
  ssh root@scopecreep chown webdav:webdav /run/secrets/webdav.htpasswd
  echo "Uploaded webdav.htpasswd to scopecreep:/run/secrets/webdav.htpasswd"
}

export -f generate
bws run -- bash -c generate
