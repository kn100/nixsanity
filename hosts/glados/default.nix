{ pkgs, lib, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/common/users.nix
    ../../modules/common/ssh.nix
    ./hardware.nix
  ];

  # NFS Server Configuration
  services.nfs.server = {
    enable = true;
    statdPort = 4000;
    lockdPort = 4001;
    mountdPort = 4002;

    exports = ''
      /mnt/backedup  faith.lan(rw,all_squash,anonuid=9996,anongid=1000,sync,no_subtree_check) 192.168.18.0/24(rw,all_squash,anonuid=9996,anongid=1000,sync,no_subtree_check)
      /mnt/burnable  faith.lan(rw,all_squash,anonuid=9996,anongid=1000,sync,no_subtree_check) 192.168.18.0/24(rw,all_squash,anonuid=9996,anongid=1000,sync,no_subtree_check)
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

  system.stateVersion = "25.11";
}
