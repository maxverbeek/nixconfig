#!/usr/bin/env sh

exec nix run 'nixpkgs#nodePackages.node2nix' -- -i node-packages.json
