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
    ../../modules/services/tailscale-proxies.nix
    inputs.sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = ../../secrets/passwords.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

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
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_6_12;

  networking.hostName = "joker";

  # Enable networking
  networking.networkmanager.enable = true;

  # ZFS Support
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "99887766";

  system.stateVersion = "25.11";
}
