# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, strings, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  systemd = {
    enableEmergencyMode = false;
  };
  # Use the GRUB 2 boot loader.
  #boot.loader.grub.enable = true;
  #boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  #boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  # networking = {
  #   hostName = "storage2";
  #   interfaces.ens18.ipv4.addresses = [{
  #       address = "172.22.99.20";
  #       prefixLength = 24;
  #   }];
  # };


  networking = {
    hostName = "storage-ng";
    # usePredictableInterfacenames = false;
    interfaces.ens18.ipv4.addresses = [{
        address = "172.22.99.20";
        prefixLength = 24;
    }];
    interfaces.ens18.ipv6.addresses = [{
        address= "2a02:8106:208:5201::20";
        prefixLength = 64;
    }];

    nameservers = [ "172.20.72.6" "9.9.9.9" "74.82.42.42" ];

    defaultGateway = {
       address = "172.22.99.1";
       interface = "ens18";
    };
    #defaultGateway6 = {
    #  address = "fe80::a800:42ff:fe7a:3246";
    #  interface = "ens18";
    #};
  };
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     wget
     vim
     screen
     zsh
     lftp
     # ceph
     lsof
     psmisc
     gitAndTools.git-annex
     gitAndTools.git
  ];

  services.ceph = {
      # enable = true;
      client.enable = true;
  };

  services.samba = {
      enable = true;
      enableNmbd = true;
      shares = { 
      xpool = {
        browseable = "yes";
              comment = "Public samba share.";
              # guest ok = "yes";
              path = "/mnt/cephfs/c3d2/files";
              # read only = false;
            };
        };
  };

  # fixme, we need a floating ip here
  # correct is floating ip 172.22.99.21
  # does not exist yet

  # secretfile does not work :(
  
  fileSystems."/mnt/cephfs" = {
    device = "172.22.99.13:6789:/";
    fsType = "ceph";
    options = [ "name=storage2" ("secret=" + (builtins.readFile("/etc/nixos/storage-secret.key"))) "noatime,_netdev" "noauto" "x-systemd.automount" "x-systemd.device-timeout=175" "users" ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.atftpd = {
    enable = true;
    root = "/mnt/cephfs/c3d2/tftp";
  };


  services.nginx = {
    enable = true;
    virtualHosts = {
      "storage-ng.hq.c3d2.de" = {
        root = "/etc/nixos/www";
        serverAliases = [ "storage" "storage2" "storageng" ];
        http2 = true;
        # addSSL = true;
        locations = {
          "/c3d2" = {
            alias = "/mnt/cephfs/c3d2/files/";
            extraConfig = ''
              autoindex on;
            '';
          };
        };
      };
    };
  };
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 
    23
    80
    443
    137 138 445 139 # samba
   ];
  networking.firewall.allowedUDPPorts = [ 
    69
    137 138 445 139 # samba
   ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.k-ot = {
     isNormalUser = true;
     uid = 1000;
    extraGroups = [ "wheel" ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?

}
