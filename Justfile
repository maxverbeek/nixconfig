switch *ARGS:
    sudo nixos-rebuild switch --flake . {{ARGS}}

apply host:
  #!/usr/bin/env bash
  set -euo pipefail
  store_path=$(nix flake prefetch --json . | jq -r '.storePath')
  nix copy --to ssh://root@{{host}} --no-check-sigs "$store_path"
  ssh root@{{host}} "nixos-rebuild switch --flake ${store_path}#{{host}}"

test:
    sudo nixos-rebuild test --flake .

deploy host ip:
    nix run github:nix-community/nixos-anywhere -- --flake .#{{host}} --target-host root@{{ip}}

update:
    just lockfile && just commit && just

lockfile:
    git pull --rebase
    nix flake update


changes := `git diff-index HEAD flake.lock`

commit:
    if [ -n "{{changes}}" ]; then
    git add flake.lock
    git commit -m "chore(flake.lock): update"
    else
    exit 1
    fi
