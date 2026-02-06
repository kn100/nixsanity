{ pkgs, ... }:

{
  users.users.kn100 = {
    isNormalUser = true;
    description = "kn100";
    extraGroups = [ "wheel" ];
    shell = pkgs.bash;
    home = "/home/kn100";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCeeAxiYj1z6WVjJ+rZGqHnKBW73g1TaL5dOtQGy1ZEzCeXkzDCiG1N3mpQHGCbiG9kRedxQTcQWHhLkYMyOU0Wp4WIKxtbXCJUuOtzbRTHWNueZ3XNVp3+nTPSMGsaTGjssHznOaz0+sScc0wW62z9bqdSAGieJ/Aked+4JNXxqVXU2+pfODN2i0WpkWiTzb6dQw/wiDp8Y72+yFNonfa8jBsbmjAXl/A8LFsK6cnoaJUjkIf90Vx4EY6dJhvKp2Qjrsc1pvEnP8rZ0TDOz6Q+H6pQ5VuheAEFns3KhJcVt05l/yskcYMSgak+tBC1ypUhhHVSjly61MTP6MBcqCR kn100@Kevins-MacBook-Pro.local"
    ];
  };
}
