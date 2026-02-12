{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common/default.nix
    ../../modules/common/ssh.nix
    ../../modules/common/users.nix
    ../../modules/services/home-assistant.nix
    ../../modules/services/mosquitto.nix
    ../../modules/services/zigbee2mqtt.nix
    ../../modules/services/jellyfin.nix
    ../../modules/services/immich.nix
    ../../modules/services/tailscale-proxies.nix
    inputs.sops-nix.nixosModules.sops
  ];

  environment.systemPackages = with pkgs; [
    nfs-utils
    sanoid
    smartmontools
    clinfo
  ];

  sops.defaultSopsFile = ../../secrets/passwords.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # bulk data storage configuration
  boot.zfs.extraPools = [ "cow" ];
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "99887766";

  services.zfs.autoScrub = {
    enable = true;
    interval = "Sunday, 04:00";
  };

  services.smartd = {
    enable = true;
    notifications.wall.enable = true;
  };

  services.sanoid = {
    enable = true;
    interval = "hourly";
    datasets."cow" = {
      useTemplate = [ "production" ];
      recursive = true;
    };
    templates.production = {
      hourly = 24;
      daily = 30;
      monthly = 3;
      yearly = 0;

      autoprune = true;
      autosnap = true;
    };
  };

  # Tailscale Virtual Sidecars
  services.tailscale-proxies = {
    authKeyFile = "/var/lib/tailscale/keys/proxy-key";
    proxies = {
      homeassistant = {
        hostname = "homeassistant";
        backendPort = 8123;
      };
      zigbee2mqtt = {
        hostname = "z2m";
        backendPort = 8080;
      };
      jellyfin = {
        hostname = "jellyfin";
        backendPort = 8096;
      };
      immich = {
        hostname = "immich";
        backendPort = 2283;
      };
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_6_12;

  networking.hostName = "joker";

  # Enable networking
  networking.networkmanager.enable = true;

  system.stateVersion = "25.11";
}
