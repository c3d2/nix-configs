# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  ympdPort = 8080;
  mpdVhost = "mpd.hq.c3d2.de";
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "pulsebert"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # specific printer drivers for our printers
    epson-escpr
    splix
    # utilities
    nix-index
    usbutils
    tmux
    vim
    git
    openssl
    # NCurses Music Player Client (Plus Plus)
    # a commandline front-end client for mpd
    # 2019-01-21 mag vater gern gleich einen schoenen lokalen Verwaltung fuer MPD haben.
#    ncmpcpp
    home-manager
    mumble
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # X11 Forwarding for mumble...
  programs.ssh.forwardX11 = true;
  services.openssh.forwardX11 = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    4713 # PulseAudio
    631 # cups
    80 443 # Web/ympd
    6600 # mpd
  ];
  networking.firewall.allowedUDPPorts = [
    631
  ];
  networking.firewall.extraCommands = ''
        iptables -I INPUT -p udp --dport mdns -d 224.0.0.251 -j ACCEPT   # zeroconf
        iptables -I OUTPUT -p udp --dport mdns -d 224.0.0.251 -j ACCEPT  # zeroconf
  '';  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    browsing = true;
    listenAddresses = [ "*:631" ];
    defaultShared = true;
    # logLevel = "debug";
    drivers = [ pkgs.gutenprint pkgs.hplip pkgs.splix ];
    extraConf =
      ''
        DefaultAuthType Basic
        <Location />
          Order allow,deny
          Allow ALL
        </Location>
        <Location /admin>
          Order allow,deny
          Allow ALL
        </Location>
        <Location /admin/conf>
          AuthType Basic
          Require user @SYSTEM
          Order allow,deny
          Allow ALL
        </Location>
        <Policy default>
          <Limit Send-Document Send-URI Hold-Job Release-Job Restart-Job Purge-Jobs Set-Job-Attributes Create-Job-Subscription Renew-Subscription Cancel-Subscription Get-Notifications Reprocess-Job Cancel-Current-Job Suspend-Current-Job Resume-Job CUPS-Move-Job>
            Require user @OWNER @SYSTEM
            Order deny,allow
          </Limit>
          <Limit Pause-Printer Resume-Printer Set-Printer-Attributes Enable-Printer Disable-Printer Pause-Printer-After-Current-Job Hold-New-Jobs Release-Held-New-Jobs Deactivate-Printer Activate-Printer Restart-Printer Shutdown-Printer Startup-Printer Promote-Job Schedule-Job-After CUPS-Add-Printer CUPS-Delete-Printer CUPS-Add-Class CUPS-Delete-Class CUPS-Accept-Jobs CUPS-Reject-Jobs CUPS-Set-Default>
            AuthType Basic
            Require user @SYSTEM
            Order deny,allow
          </Limit>
          <Limit Cancel-Job CUPS-Authenticate-Job>
            Require user @OWNER @SYSTEM
            Order deny,allow
          </Limit>
          <Limit All>
            Order deny,allow
          </Limit>
        </Policy>
      '';

  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  # PulseAudio as-a-Service
  hardware.pulseaudio.systemWide = true;
  hardware.pulseaudio.tcp.anonymousClients.allowedIpRanges = [
    "127.0.0.0/8" "::1/128"
    "172.22.99.0/24" "2a02:8106:208:5201:58::/64"
  ];
  hardware.pulseaudio.tcp.enable = true;
  hardware.pulseaudio.zeroconf.publish.enable = true;

  # tell Avahi to publish CUPS and PulseAudio
  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.userServices = true;
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."k-ot" = {
    extraGroups = ["audio" "wheel"]; # allow k-ot to use PulseAudio
    isNormalUser = true;
    uid = 1000;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?


  # vater hoerte, dass menschen im space gern mpd fuer das abspielen von musik erwarten wuerden
  ####	https://nixos.org/nixos/options.html#services.mpd.enable
  services.mpd = { 
    enable=true;
    dbFile = null;
    network.listenAddress = "any";
    musicDirectory = "/mnt/storage/Music";
####    musicDirectory = "nfs://storage.hq.c3d2.de:/mnt/zroot/storage/rpool/Music";
    extraConfig = ''
####	music_directory "nfs://storage.hq.c3d2.de:/mnt/zroot/storage/rpool/Music"
####
	audio_output {
		type "pulse"
		name "/proc"
	}

	audio_output {
		type "pulse"
		name "SDK"
		server "dacbert.hq.c3d2.de"
	}

####	mpd startet bei der option nicht mehr
	database {
		plugin "proxy"
    	####	vater was here!
    	####	jail (auf storage)
    	####	externe erstellung der datenbank von mpd in der naehe der ablage der daten
		host "172.22.99.98"
	}

####	ausschalten der automatischen aktualisierung der datenbank von mpd
####	angeblich gibt es 2019-02-13 probleme, die zum absturz vom dienst mpd fuehren
####	wenn das problem behoben ist, dann kann die option wieder entfernt werden
	auto_update "no"
	'';
  };

  # mpd likes to crash a lot while indexing, so...
  systemd.services.mpd.serviceConfig.Restart="on-failure";

  services.caddy = {
    enable = true;
    agree = true;
    # TODO: add auth?
    config = ''
        ${mpdVhost} {
          proxy / localhost:${toString ympdPort}
        }

        :80 {
          redir https://${mpdVhost}{uri}
        }
    '';
  };


  fileSystems."/mnt/storage" = {
    device = "storage.hq.c3d2.de:/mnt/zroot/storage/rpool";
    fsType = "nfs";
  };

####	nur zum spielen mit dem bereitstellen von einer per nfs angebundenen datei als datenbank fuer mpd
  fileSystems."/mnt/service-data/mpd_index" = {
    device = "storage.hq.c3d2.de:/mnt/zroot/iocage/jails/mpd_index/root/var/mpd/.mpd";
    fsType = "nfs";
  };

  # MPD music playing daemon with webinterface
  services.ympd = {
    enable = true;
    webPort = toString ympdPort;
  };
  nixpkgs.config.packageOverrides = pkgs: with pkgs; {
    ympd = ympd.overrideAttrs (oldAttrs: {
      src = fetchFromGitHub {
        owner = "c3d2";
        repo = "ympd";
        rev = "feature/somafm_browser";
        sha256 = "1a1m3lhyhm3xmi59pamfpwias31bl2jwqd71qxs4d0vzplpd7rml";
      };
    });
  };
  
}
