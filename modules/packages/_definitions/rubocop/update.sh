#!/bin/sh

bundle lock
nix run "nixpkgs#bundix"
