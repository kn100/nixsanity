{ config, pkgs, ... }:

{
  services.immich = {
    enable = true;
    accelerationDevices = null;
    openFirewall = true;
    mediaLocation = "/cow/backedup/immich2";
  };

  users.users.immich.extraGroups = [
    "video"
    "render"
    "cowaccess"
  ];
}
