{ config, pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      sonarr = {
        image = "lscr.io/linuxserver/sonarr";
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Canada/Eastern";
        };
        volumes = [
          "/var/lib/arr-stack/sonarr:/config"
          "/cow/burnable/arr/media/tv:/tv"
          "/cow/burnable/qbittorrent/downloads/organized-tv:/oldtv"
          "/cow/burnable/qbittorrent/downloads/:/chaos"
          "/cow/burnable/arr/media/movies:/movies"
          "/cow/burnable/qbittorrent/downloads/organized-movies:/oldmovies"
          "/cow/burnable/arr/downloads:/downloads"
        ];
        ports = [ "8989:8989" ];
        extraOptions = [ "--network=arr-net" ];
      };

      radarr = {
        image = "lscr.io/linuxserver/radarr";
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Canada/Eastern";
        };
        volumes = [
          "/var/lib/arr-stack/radarr:/config"
          "/cow/burnable/arr/media/movies:/movies"
          "/cow/burnable/arr/downloads:/downloads"
        ];
        ports = [ "7878:7878" ];
        extraOptions = [ "--network=arr-net" ];
      };

      prowlarr = {
        image = "lscr.io/linuxserver/prowlarr";
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Canada/Eastern";
        };
        volumes = [
          "/var/lib/arr-stack/prowlarr:/config"
        ];
        ports = [ "9696:9696" ];
        extraOptions = [ "--network=arr-net" ];
      };

      homarr = {
        image = "ghcr.io/homarr-labs/homarr";
        environment = {
          TZ = "Canada/Eastern";
          SECRET_ENCRYPTION_KEY = "45f13d57eac895633382a2f1065a428c8b58b6d7af2ffabb494a7a655bc12e0d";
        };
        volumes = [
          "/var/lib/arr-stack/homarr/configs:/app/data/configs"
          "/var/lib/arr-stack/homarr/data:/data"
          "/var/lib/arr-stack/homarr/icons:/app/public/icons"
        ];
        ports = [ "7575:7575" ];
        extraOptions = [ "--network=arr-net" ];
      };

      qbittorrent = {
        image = "lscr.io/linuxserver/qbittorrent";
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Canada/Eastern";
          WEBUI_PORT = "8081";
        };
        volumes = [
          "/var/lib/arr-stack/qbittorrent:/config"
          "/cow/burnable/arr/downloads/movies:/downloads/movies"
          "/cow/burnable/arr/downloads/tv:/downloads/tv"
          "/cow/burnable/arr/media/tv:/tv"
          "/cow/burnable/arr/media/movies:/movies"
        ];
        ports = [
          "8081:8081"
          "6881:6881"
          "6881:6881/udp"
        ];
        extraOptions = [ "--network=arr-net" ];
      };
    };
  };

  # Custom systemd service to create the podman network
  systemd.services.podman-network-arr-net = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.podman}/bin/podman network create arr-net";
      ExecStop = "${pkgs.podman}/bin/podman network rm arr-net";
    };
    scriptArgs = "";
    wantedBy = [ "multi-user.target" ];
  };

  # Ensure containers start after the network is created
  systemd.services = {
    podman-jackett.after = [ "podman-network-arr-net.service" ];
    podman-sonarr.after = [ "podman-network-arr-net.service" ];
    podman-radarr.after = [ "podman-network-arr-net.service" ];
    podman-prowlarr.after = [ "podman-network-arr-net.service" ];
    podman-homarr.after = [ "podman-network-arr-net.service" ];
    podman-qbittorrent.after = [ "podman-network-arr-net.service" ];
  };

  # Ensure the config directories exist
  systemd.tmpfiles.rules = [
    "d /var/lib/arr-stack 0755 1000 1000 -"
    "d /var/lib/arr-stack/jackett 0755 1000 1000 -"
    "d /var/lib/arr-stack/sonarr 0755 1000 1000 -"
    "d /var/lib/arr-stack/radarr 0755 1000 1000 -"
    "d /var/lib/arr-stack/prowlarr 0755 1000 1000 -"
    "d /var/lib/arr-stack/homarr 0755 1000 1000 -"
    "d /var/lib/arr-stack/homarr/configs 0755 1000 1000 -"
    "d /var/lib/arr-stack/homarr/data 0755 1000 1000 -"
    "d /var/lib/arr-stack/homarr/icons 0755 1000 1000 -"
    "d /var/lib/arr-stack/qbittorrent 0755 1000 1000 -"
  ];

  networking.firewall.allowedTCPPorts = [
    9117
    8989
    7878
    9696
    7575
    8081
    6881
  ];
  networking.firewall.allowedUDPPorts = [ 6881 ];
}
