#!/usr/bin/env sh

rm -f ./node-env.nix ./node-packages.nix

exec nix run 'unstable#nodePackages.node2nix' -- --nodejs-16 -i node-packages.json --pkg-name nodejs-16_x
