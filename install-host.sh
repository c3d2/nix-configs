#!/usr/bin/env bash

set -e

REPO=nix-configs
if [ -d $REPO ]; then
	cd $REPO
	git pull --ff-only
else
	git clone https://github.com/c3d2/$REPO.git $REPO
fi

for OLDCFG in /etc/nixos/{hardware-,}configuration.nix; do
	if [ -f $OLDCFG ]; then
		sudo mv ${OLDCFG}{,.old}
	fi
done

sudo ln -s $HOME/$REPO/hosts/`hostname -s`/configuration.nix /etc/nixos/configuration.nix
ls -l /etc/nixos/configuration.nix

