.PHONY: switch test update lockfile

switch:
	sudo nixos-rebuild switch --flake .

test:
	sudo nixos-rebuild test --flake .

update:
	sh -c "make lockfile && make commit && make"

lockfile:
	git pull --rebase
	nix flake update

CHANGES := $(shell git diff-index HEAD flake.lock)

ifneq ($(strip $(CHANGES)),)
commit:
	git add flake.lock
	git commit -m "chore(flake.lock): update"
else
commit:
	exit 1
endif
