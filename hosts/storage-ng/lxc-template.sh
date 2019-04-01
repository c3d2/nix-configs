#!/usr/bin/env bash

nix-build -I nixos-config=./lxc-template.nix '<nixpkgs/nixos>' -A config.system.build.tarball
