# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/profiles/minimal.nix>
      ./proxy.nix
    ];
  nix.useSandbox = false;
  nix.maxJobs = lib.mkDefault 2;
  nix.buildCores = lib.mkDefault 16;

  boot.isContainer = true;
  # /sbin/init
  boot.loader.initScript.enable = true;
  boot.loader.grub.enable = false;

  fileSystems."/" = { fsType = "rootfs"; device = "rootfs"; };

  networking.hostName = "public-access-proxy";
  networking.defaultGateway = "172.22.99.4";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  services.openssh = {
    enable = true;
    permitRootLogin = "prohibit-password";
    ports = [ 1122 ];
  };

  services.my.proxy = {
    enable = true;
    proxyHosts = [
      {
        hostNames = [ "mdm.arkom.men" ];
        proxyTo = { host = "cloud.bombenverleih.de"; httpPort = 80; httpsPort = 443; };
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ 
    80
    443
   ];

  users.extraUsers.k-ot = {
    inNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
  };

  system.stateVersion = "18.09"; # Did you read the comment?

}
