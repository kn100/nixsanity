{ pkgs, ... }:

{
  # Groups
  users.groups.cowaccess.gid = 1000;
  users.groups.kn100.gid = 1001;

  # Main user
  users.users.kn100 = {
    isNormalUser = true;
    description = "kn100";
    extraGroups = [
      "wheel"
      "cowaccess"
    ];
    shell = pkgs.bash;
    home = "/home/kn100";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCeeAxiYj1z6WVjJ+rZGqHnKBW73g1TaL5dOtQGy1ZEzCeXkzDCiG1N3mpQHGCbiG9kRedxQTcQWHhLkYMyOU0Wp4WIKxtbXCJUuOtzbRTHWNueZ3XNVp3+nTPSMGsaTGjssHznOaz0+sScc0wW62z9bqdSAGieJ/Aked+4JNXxqVXU2+pfODN2i0WpkWiTzb6dQw/wiDp8Y72+yFNonfa8jBsbmjAXl/A8LFsK6cnoaJUjkIf90Vx4EY6dJhvKp2Qjrsc1pvEnP8rZ0TDOz6Q+H6pQ5VuheAEFns3KhJcVt05l/yskcYMSgak+tBC1ypUhhHVSjly61MTP6MBcqCR kn100@Kevins-MacBook-Pro.local"
    ];
  };

  # NFS/Samba users
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
}
