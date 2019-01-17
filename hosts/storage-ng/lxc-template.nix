# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/profiles/minimal.nix>
    ];
  nix.useSandbox = false;
  nix.maxJobs = lib.mkDefault 4;

  boot.isContainer = true;
  # /sbin/init
  boot.loader.initScript.enable = true;
  boot.loader.grub.enable = false;
  #boot.supportedFilesystems = ["zfs" "ext2" "ext3" "vfat" "fat32" "bcache" "bcachefs"];

  fileSystems."/" = { fsType = "rootfs"; device = "rootfs"; };

  networking.hostName = "nixbert"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.useNetworkd = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = lib.mkForce [ "en_US.UTF-8/UTF-8" ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim
  ];

  # Create a few files early before packing tarball for Proxmox
  # architecture/OS detection.
  system.extraSystemBuilderCmds = 
      ''
          mkdir -m 0755 -p $out/bin
          ln -s ${pkgs.bash}/bin/bash $out/bin/sh
          mkdir -m 0755 -p $out/sbin
          ln -s ../init $out/sbin/init
      '';

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
