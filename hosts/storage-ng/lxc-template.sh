#!/usr/bin/env bash

# Doesn't boot in Proxmox, use nixos-install to generate an image instead!

nix-build -E '(import ../../nixpkgs/nixos/release.nix { configuration = import ./lxc-template.nix; }).containerTarball.x86_64-linux'
