{ pkgs, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/common/users.nix
    ../../modules/common/ssh.nix
    ./hardware.nix
  ];

  networking.hostName = "faith";
  networking.networkmanager.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  services.qemuGuest.enable = true;

  # NFS client mounts
  fileSystems."/mnt/backedup" = {
    device = "glados.lan:/mnt/backedup";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "soft"
      "intr"
    ];
  };

  fileSystems."/mnt/burnable" = {
    device = "glados.lan:/mnt/burnable";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "soft"
      "intr"
    ];
  };

  system.stateVersion = "25.11";
}
