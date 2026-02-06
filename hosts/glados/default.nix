{ pkgs, lib, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/common/users.nix
    ../../modules/common/ssh.nix
    ./hardware.nix
  ];

  networking.hostName = "glados";

  # NFS Server Configuration
  services.nfs.server = {
    enable = true;
    statdPort = 4000;
    lockdPort = 4001;
    mountdPort = 4002;

    exports = ''
      /mnt/backedup  faith.lan(rw,all_squash,anonuid=9996,anongid=1000,sync,no_subtree_check)
      /mnt/burnable  faith.lan(rw,all_squash,anonuid=9996,anongid=1000,sync,no_subtree_check)
    '';
  };

  # Open Firewall for NFS
  networking.firewall.allowedTCPPorts = [
    111
    2049
    4000
    4001
    4002
  ];
  networking.firewall.allowedUDPPorts = [
    111
    2049
    4000
    4001
    4002
  ];

  # DNS stability in LXC
  services.resolved = {
    enable = true;
    extraConfig = ''
      Cache=true
      CacheFromLocalhost=true
    '';
  };

  # Additional Users/Groups for NFS
  users.groups.cowaccess.gid = 1000;
  users.groups.kn100.gid = 1001;

  users.users.kn100.extraGroups = [ "cowaccess" ];

  users.users.cowrw = {
    isNormalUser = true;
    uid = 9996;
    group = "cowaccess";
    description = "Samba Read-Write User";
    home = "/home/cowrw";
    createHome = true;
    shell = pkgs.bash;
  };

  users.users.cowro = {
    isNormalUser = true;
    uid = 9997;
    group = "cowaccess";
    description = "Samba Read-Only User";
    home = "/home/cowro";
    createHome = true;
    shell = pkgs.bash;
  };

  system.stateVersion = "25.11";
}
