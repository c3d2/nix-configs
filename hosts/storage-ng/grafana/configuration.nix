{ config, pkgs, lib, ... }:

{
  imports =
    [ ../../../lib/lxc-container.nix
      ../../../lib/shared.nix
    ];

  networking.hostName = "grafana";
  networking.useNetworkd = true;
  networking.defaultGateway = "172.22.99.4";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
  ];

  # http https
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  # collectd
  networking.firewall.allowedUDPPorts = [ 25826 ];

  services.caddy = {
    enable = true;
    agree = true;
    config = ''
        grafana.hq.c3d2.de
        proxy / localhost:3000
    '';
  };
  services.grafana = {
    enable = true;
    auth.anonymous = {
      enable = true;
      org_name = "Chaos";
    };
    users.allowSignUp = true;
  };
  services.influxdb =
    let
      collectdTypes = pkgs.stdenv.mkDerivation {
        name = "collectd-types";
        src = ./.;
        buildInputs = [ pkgs.collectd ];
        buildPhase = ''
            mkdir -p $out/share/collectd
            cat ${pkgs.collectd}/share/collectd/types.db >> $out/share/collectd/types.db
            echo "stations  value:GAUGE:0:U" >> $out/share/collectd/types.db
        '';
        installPhase = ''
            cp -r . $out
        '';
      };
    in {
      enable = true;
      extraConfig = {
        logging.level = "debug";
        collectd = [{
          enabled = true;
          database = "collectd";
          typesdb = "${collectdTypes}/share/collectd/types.db";
        }];
      };    
    };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}

