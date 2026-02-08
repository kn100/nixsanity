{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.services.tailscale-proxies;
in
{
  options.services.tailscale-proxies = {
    authKeyFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Global path to a file containing a Tailscale auth key used if not specified per proxy.";
    };
    proxies = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            hostname = mkOption {
              type = types.str;
              description = "The hostname this proxy should use on the Tailnet.";
            };
            backendPort = mkOption {
              type = types.port;
              description = "The local port to proxy to on port 443 of the Tailnet.";
            };
            extraPorts = mkOption {
              type = types.attrsOf types.port;
              default = { };
              description = "Extra port mappings. Key is Tailnet port, value is local backend port.";
            };
            authKeyFile = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = "Path to a file containing a Tailscale auth key. Defaults to global config.";
            };
          };
        }
      );
      default = { };
    };
  };

  config = mkIf (cfg.proxies != { }) {
    # Ensure the parent directory for state exists
    systemd.tmpfiles.rules = [
      "d /var/lib/tailscale-proxies 0750 root root -"
    ];

    # Create services for each proxy
    systemd.services = mapAttrs' (
      name: value:
      let
        authKeyFile = if value.authKeyFile != null then value.authKeyFile else cfg.authKeyFile;
      in
      nameValuePair "tailscaled-${name}" {
        description = "Tailscale personality for ${name}";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          StateDirectory = "tailscale-proxies/${name}";
          RuntimeDirectory = "tailscale-proxies/${name}";
          ExecStart = ''
            ${pkgs.tailscale}/bin/tailscaled \
              --tun=userspace-networking \
              --socket=/run/tailscale-proxies/${name}/tailscaled.sock \
              --statedir=/var/lib/tailscale-proxies/${name} \
              --state=/var/lib/tailscale-proxies/${name}/tailscaled.state \
              --port=0
          '';
          Restart = "on-failure";
        };

        # This part performs the 'up' and 'serve' configuration
        postStart = ''
          # Wait for socket to appear with a timeout
          for i in {1..50}; do
            if [ -S /run/tailscale-proxies/${name}/tailscaled.sock ]; then
              break
            fi
            sleep 0.2
          done

          if [ ! -S /run/tailscale-proxies/${name}/tailscaled.sock ]; then
            echo "Tailscale socket never appeared"
            exit 1
          fi

          # Bring the node up
          ${pkgs.tailscale}/bin/tailscale --socket=/run/tailscale-proxies/${name}/tailscaled.sock up \
            --hostname=${value.hostname} \
            --authkey=$(cat ${authKeyFile}) \
            --advertise-tags=tag:vtwo

          # Configure the HTTPS serve (default port 443)
          ${pkgs.tailscale}/bin/tailscale --socket=/run/tailscale-proxies/${name}/tailscaled.sock serve \
            --bg http://localhost:${toString value.backendPort}

          # Configure extra ports
          ${concatStringsSep "\n" (
            mapAttrsToList (tsPort: backendPort: ''
              ${pkgs.tailscale}/bin/tailscale --socket=/run/tailscale-proxies/${name}/tailscaled.sock serve \
                --bg ${tsPort} http://localhost:${toString backendPort}
            '') value.extraPorts
          )}
        '';
      }
    ) cfg.proxies;
  };
}
