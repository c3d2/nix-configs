{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.my.services.proxy;

in {

  options.my.serices.proxy = {

    enable = mkOption {
      default = false;
      description = "whether to enable proxy";
      type = types.bool;
    };

    proxyHosts = mkOption {
      type = types.listOf (types.submodule (
        {
          options = {
            hostNames = mkOption {
              type = types.listOf types.str;
              default = [];
              description = ''
                Proxy these hostnames.
              '';
            };
            proxyTo = mkOption {
              type = types.submodule (
                {
                  options = {
                    host = mkOption {
                      type = types.nullOr types.string;
                      default = null;
                      description = ''
                        Host to forward traffic to.
                        Any hostname may only be used once
                      '';
                    };
                    httpPort = mkOption {
                      type = types.int;
                      default = 80;
                      description = ''
                        Port to forward http to.
                      '';
                    };
                    httpsPort = mkOption {
                      type = types.int;
                      default = 443;
                      description = ''
                        Port to forward http to.
                      '';
                    };
                  };
                });
              description = ''
                { host = /* ip or fqdn */; httpPort = 80; httpsPort = 443; } to proxy to
              '';
              default = {};
            };

        }));
      default = [];
      example = [
        { hostNames = [ "test.hq.c3d2.de" "test.c3d2.de" ];
          proxyTo = { host = "172.22.99.99"; httpPort = 80; httpsPort = 443; };
        }
      ];
    };

  };

  config = mkIf cfg.enable {

    services.haproxy = {
      enable = true;
      config = ''
        frontend http-in
          bind *:80
          default_backend proxy-backend-http
  
        backend proxy-backend-http
          ${concatMapStringSep "\n" (proxyHost:
            optionalString (proxyHost.hostNames != [] && proxyHost.proxyTo.host != null) (
              concatMapStringSep "\n" (hostname: ''
                use-server ${hostname}-http if { req.hdr(host) -i ${hostname} }
                server ${hostname}-http ${proxyHost.proxyTo.host}:${proxyHost.proxyTo.httpPort} weight 0
              ''
              ) (attrValues proxyHost.hostnames)
            )
          ) (attrValues cfg.proxyHosts)
          }

        frontend https-in
          bind *:443
          default_backend proxy-backend-https

        backend proxy-backend-https
          ${concatMapStringSep "\n" (proxyHost:
            optionalString (proxyHost.hostNames != [] && proxyHost.proxyTo.host != null) (
              concatMapStringSep "\n" (hostname: ''
                use-server ${hostname}-https if { req.ssl_sni -i ${hostname} }
                server ${hostname}-https ${proxyHost.proxyTo.host}:${proxyHost.proxyTo.httpsPort} weight 0
              ''
              ) (attrValues proxyHost.hostnames)
            )
          ) (attrValues cfg.proxyHosts)
          }
      '';
    };

}
