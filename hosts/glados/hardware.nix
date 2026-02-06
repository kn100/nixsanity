{ modulesPath, lib, ... }:

{
  imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];

  boot.isContainer = true;

  systemd.suppressedSystemUnits = [
    "sys-kernel-debug.mount"
    "sys-kernel-gui.mount"
  ];

  systemd.mounts = [
    {
      where = "/sys/kernel/debug";
      enable = false;
    }
    {
      where = "/sys/kernel/config";
      enable = false;
    }
  ];

  services.getty.autologinUser = lib.mkDefault "root";

  nix.settings.sandbox = false;

  proxmoxLXC = {
    manageNetwork = false;
    manageHostName = false;
    privileged = true;
  };
}
