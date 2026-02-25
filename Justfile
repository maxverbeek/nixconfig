switch *ARGS:
    sudo nixos-rebuild switch --flake . {{ARGS}}

test:
    sudo nixos-rebuild test --flake .

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
