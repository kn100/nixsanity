{ config, pkgs, ... }:

{
  sops.secrets.grafana_admin_password = {
    owner = "grafana";
  };

  # Prometheus Configuration
  services.prometheus = {
    enable = true;
    port = 9090;
    retentionTime = "90d";

    globalConfig.scrape_interval = "15s";

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [ { targets = [ "localhost:9090" ]; } ];
      }
      {
        job_name = "node";
        static_configs = [ { targets = [ "localhost:9100" ]; } ];
      }
      {
        job_name = "cadvisor";
        static_configs = [ { targets = [ "localhost:9099" ]; } ];
      }
    ];

    # Recording rules for long-term aggregation
    rules = [
      (builtins.toJSON {
        groups = [
          {
            name = "node_aggregates_5m";
            rules = [
              {
                record = "node:cpu_usage_5m";
                expr = "100 - (avg by (instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)";
              }
              {
                record = "node:memory_usage_bytes_5m";
                expr = "node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes";
              }
              {
                record = "node:disk_io_5m";
                expr = "sum by (instance) (irate(node_disk_io_time_seconds_total[5m]))";
              }
              {
                record = "node:network_traffic_5m";
                expr = "sum by (instance) (irate(node_network_receive_bytes_total[5m])) + sum by (instance) (irate(node_network_transmit_bytes_total[5m]))";
              }
            ];
          }
          {
            name = "container_aggregates_5m";
            rules = [
              {
                record = "container:cpu_usage_5m";
                expr = "sum by (name) (rate(container_cpu_usage_seconds_total{name!=\"\"}[5m])) * 100";
              }
              {
                record = "container:memory_usage_5m";
                expr = "sum by (name) (container_memory_usage_bytes{name!=\"\"})";
              }
            ];
          }
        ];
      })
    ];
  };

  # Node Exporter
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [
      "systemd"
      "zfs"
    ];
    disabledCollectors = [
      "arp"
      "bcache"
      "bonding"
      "infiniband"
      "ipvs"
      "nfs"
      "nfsd"
      "tapestats"
      "xfs"
    ];
  };

  # cAdvisor via Podman
  virtualisation.oci-containers.containers.cadvisor = {
    image = "gcr.io/cadvisor/cadvisor:v0.55.1";
    ports = [ "127.0.0.1:9099:8080" ];
    volumes = [
      "/:/rootfs:ro"
      "/sys:/sys:ro"
      "/sys/fs/cgroup:/sys/fs/cgroup:ro"
      "/var/lib/containers/storage/overlay-containers/volatile-containers.json:/var/lib/containers/storage/overlay-containers/containers.json:ro"
      "/run/containers/storage:/run/containers/storage:ro"
      "/run/podman/podman.sock:/var/run/docker.sock:ro"
      "/dev/disk/:/dev/disk:ro"
      "/etc/machine-id:/etc/machine-id:ro"
    ];
    extraOptions = [
      "--privileged"
      "--device=/dev/kmsg"
      "--no-healthcheck"
      "--cgroupns=host"
    ];
    cmd = [
      "-podman=unix:///var/run/docker.sock"
    ];
  };

  # Grafana Configuration
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "grafana.fluffy-perch.ts.net"; # Adjusted for user's tailnet domain pattern seen in history
      };
      security = {
        admin_password = "$__file{${config.sops.secrets.grafana_admin_password.path}}";
      };
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://localhost:9090";
          isDefault = true;
        }
      ];
      dashboards.settings.providers = [
        {
          name = "Default Dashboards";
          options.path = "/var/lib/grafana/dashboards";
        }
      ];
    };
  };

  # Provision dashboard JSON files via tmpfiles (to avoid huge nix store entries if they change)
  # We use official dashboard IDs: 1860 (Node Exporter Full), 14282 (CADvisor)
  systemd.tmpfiles.rules = [
    "d /var/lib/grafana/dashboards 0755 grafana grafana -"
  ];

  # Note: Actually downloading or embedding large JSONs here is messy.
  # For the "starter" experience, the user can import 1860 and 14282 in the UI,
  # but I'll set up the datasource so it's ready to go.

  networking.firewall.allowedTCPPorts = [
    9090
    3000
  ];
}
