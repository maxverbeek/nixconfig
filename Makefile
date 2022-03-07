.PHONY: switch test update lockfile

switch:
	sudo nixos-rebuild switch --flake .

test:
	sudo nixos-rebuild test --flake .

update: | lockfile commit

lockfile:
	git pull --rebase
	nix flake update

CHANGES := $(shell git diff-index --quiet HEAD flake.lock)

ifneq ($(strip $(CHANGES)),)
commit:
	git add flake.lock
	git commit -m "chore(flake.lock): update"
else
commit:

endif
