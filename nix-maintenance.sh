#!/usr/bin/env bash

set -x
set -e

sudo nix-channel --update
time nix-env -- -u \*
time sudo nixos-rebuild switch
time sudo nix-collect-garbage -d
time sudo nix-store --optimise
