#!/usr/bin/env bash
# Test block-store-glob.sh regex: wildcard in the FIRST store path component
# must block; wildcard deeper inside one resolved path must pass.
h="$(dirname "$0")/block-store-glob.sh"
S=/nix/store
t() {
  local desc=$1 cmd=$2 want=$3 got
  if printf '{"tool_input":{"command":%s}}' "$(jq -Rn --arg c "$cmd" '$c')" | "$h" >/dev/null 2>&1; then
    got=ALLOW
  else
    got=BLOCK
  fi
  [ "$got" = "$want" ] && echo "  pass  $got  $desc" || echo "  FAIL  got=$got want=$want  $desc"
}
echo "must BLOCK (wildcard globs the store root):"
t "bare store glob"      "ls $S/"'*'                          BLOCK
t "hash-prefix glob"     "grep -r foo $S/"'*-source'          BLOCK
echo "must ALLOW (wildcard inside one already-resolved path):"
t "glob .nix in subdir"  "ls $S/24fxx0000000000000000000000000-source/modules/"'*.nix'  ALLOW
t "glob bin contents"    "cat $S/abcdef0000000000000000000000-source/bin/"'*'           ALLOW
echo "unrelated:"
t "plain cwd glob"       'ls *.nix'                           ALLOW
