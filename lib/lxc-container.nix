{ pkgs, lib, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/profiles/minimal.nix>
      <nixpkgs/nixos/modules/profiles/docker-container.nix>
    ];
  nix.useSandbox = false;
  nix.maxJobs = lib.mkDefault 1;
  nix.buildCores = lib.mkDefault 4;

  boot.isContainer = true;
  # /sbin/init
  boot.loader.initScript.enable = true;
  boot.loader.grub.enable = false;

  # Create a few files early before packing tarball for Proxmox
  # architecture/OS detection.
  system.extraSystemBuilderCmds = 
      ''
          mkdir -m 0755 -p $out/bin
          ln -s ${pkgs.bash}/bin/bash $out/bin/sh
          mkdir -m 0755 -p $out/sbin
          ln -s ../init $out/sbin/init
      '';

  fileSystems."/" = { fsType = "rootfs"; device = "rootfs"; };

  # Required for remote deployment
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = (import ../secrets/lib/authorized_keys).admins;
}
