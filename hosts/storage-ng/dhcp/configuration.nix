{ config, pkgs, lib, ... }:

{
  imports =
    [ ../../../lib/lxc-container.nix
      ../../../lib/shared.nix
    ];

  networking.hostName = "dhcp";
  networking.defaultGateway = "172.22.99.1";
  networking.nameservers = [ "172.20.72.6" ];
  networking.interfaces.eth0 = {
    ipv4.addresses = [ {
      address = "172.22.99.254";
      prefixLength = 24;
    } ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
  ];

  # dhcp
  networking.firewall.allowedUDPPorts = [ 67 68 ];

  services.dhcpd4 = {
    enable = true;
    interfaces = [ "eth0" ];
    extraConfig = builtins.readFile ../../../secrets/hosts/dhcp/config;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
