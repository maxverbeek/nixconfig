#!/usr/bin/env sh

rm -f ./node-env.nix ./node-packages.nix

exec nix run 'unstable#nodePackages.node2nix' -- -i package.json -l package-lock.json --no-bypass-cache
