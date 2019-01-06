# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  #x11vnc-service = with pkgs; import ./x11vnc-service.nix { inherit stdenv pkgs; };
in
{
  nixpkgs.config.allowUnfree = true;
  nix = {
    useSandbox = true;
    buildCores = 2;
  };
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_4_19;

  networking.hostName = "glotzbert"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.defaultGateway = "172.22.99.4";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "de";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim x11vnc
  ];

  systemd.user.services.x11vnc = {
    description = "X11 VNC server";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = ''
          ${pkgs.x11vnc}/bin/x11vnc -shared -forever -passwd k-ot
      '';
      RestartSec = 3;
      Restart = "always";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    # Users must be in "audio" group
    systemWide = true;
    support32Bit = true;
    zeroconf.discovery.enable = true;
    zeroconf.publish.enable = true;
    tcp = {
      enable = true;
      anonymousClients.allowAll = true;
    };
    extraConfig = ''
      load-module module-tunnel-sink server=cibert.hq.c3d2.de
    '';
    extraClientConf = ''
      default-server = cibert.hq.c3d2.de
    '';
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "de";
  services.xserver.xkbOptions = "eurosign:e";

  services.xserver.displayManager = {
    lightdm = {
      enable = true;
      autoLogin = {
        enable = true;
        user = "k-ot";
      };
    };
  };
  services.xserver.desktopManager = {
    gnome3.enable = true;
    kodi.enable = false;
    default = "gnome";
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups."k-ot" = { gid = 1000; };
  users.users."k-ot" = {
    password = "k-ot";
    isNormalUser = true;
    uid = 1000;
    group = "k-ot";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJJTSJdpDh82486uPiMhhyhnci4tScp5uUe7156MBC8 astro" ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?

}
