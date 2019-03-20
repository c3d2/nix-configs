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

  #networking.hostName = "docker-registry"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  #networking.useNetworkd = true;

  networking = {
    hostName = "registry";
    # usePredictableInterfacenames = false;
    interfaces.eth0.ipv4.addresses = [{
        address = "172.22.99.34";
        prefixLength = 24;
    }];
    interfaces.eth0.ipv6.addresses = [{
        address= "2a02:8106:208:5201::34";
        prefixLength = 64;
    }];

    dhcpcd.denyInterfaces = [ "eth0" ];

    nameservers = [ "8.8.8.8" "9.9.9.9" ];

    defaultGateway = {
       address = "172.22.99.1";
       interface = "eth0";
       metric = 10;
    };
    #defaultGateway6 = {
    #  address = "fe80::a800:42ff:fe7a:3246";
    #  interface = "ens18";
    #};
  };
  
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22
    80
    443
    5000
   ]; 

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
    wget
    vim
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
  
  services.dockerRegistry.enable = true;

  services.nginx.enable = true;
  services.nginx.virtualHosts."registry.hq.c3d2.de" = {
    enableACME = true;
    enableSSL = true;
    # forceSSL = true;
    locations.".well-known/acme-challenge/" = {
           root = "/var/lib/acme/acme-challenge/.well-known/acme-challenge/";
    };
    locations."/" = {
           proxyPass = "http://localhost:5000";
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}


