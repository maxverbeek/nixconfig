switch *ARGS:
    git pull --rebase --autostash
    nixos-rebuild switch --sudo --flake . {{ARGS}}

apply host:
  #!/usr/bin/env bash
  set -euo pipefail
  store_path=$(nix flake prefetch --json . | jq -r '.storePath')
  nix copy --to ssh://root@{{host}} --no-check-sigs "$store_path"
  ssh root@{{host}} "nixos-rebuild switch --flake ${store_path}#{{host}}"

test:
    nixos-rebuild test --sudo --flake .

deploy host ip:
    nix run github:nix-community/nixos-anywhere -- --flake .#{{host}} --target-host root@{{ip}}

update:
    just lockfile && just commit && just

# CI owns the server/shared inputs; update laptop-only inputs here,
# e.g. `just lockfile barbell`. No args = full update (rarely needed).
lockfile *INPUTS:
    git pull --rebase --autostash
    nix flake update {{INPUTS}}


changes := `git diff-index HEAD flake.lock`

commit:
    if [ -n "{{changes}}" ]; then
    git add flake.lock
    git commit -m "chore(flake.lock): update"
    else
    exit 1
    fi
