{ config, pkgs, ... }:

{
  sops.secrets.restic_b2_account_id = { };
  sops.secrets.restic_b2_account_key = { };
  sops.secrets.restic_password = { };

  sops.templates.restic_b2_env = {
    owner = "immich";
    content = ''
      B2_ACCOUNT_ID=${config.sops.placeholder.restic_b2_account_id}
      B2_ACCOUNT_KEY=${config.sops.placeholder.restic_b2_account_key}
    '';
  };

  services.restic.backups = {
    immich-new-library = {
      user = "immich";
      # NOTE: Replace 'immich-new-library-bucket' with your actual B2 bucket name
      repository = "b2:immich-new-library-bucket";
      initialize = true;
      passwordFile = config.sops.secrets.restic_password.path;
      environmentFile = config.sops.templates.restic_b2_env.path;
      paths = [
        "/cow/backedup/immich2/upload"
        "/cow/backedup/immich2/library"
        "/cow/backedup/immich2/profile"
        "/cow/backedup/immich2/backups"
      ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
      pruneOpts = {
        keepDaily = 7;
        keepWeekly = 4;
        keepMonthly = 3;
      };
      extraBackupArgs = [ "--exclude-caches" ];
    };

    immich-old-library = {
      user = "immich";
      # NOTE: Replace 'immich-old-library-bucket' with your actual B2 bucket name
      repository = "b2:immich-old-library-bucket";
      initialize = true;
      passwordFile = config.sops.secrets.restic_password.path;
      environmentFile = config.sops.templates.restic_b2_env.path;
      paths = [
        "/cow/backedup/immich/photos"
        "/cow/backedup/immich/import"
      ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
      pruneOpts = {
        keepDaily = 7;
        keepWeekly = 4;
        keepMonthly = 3;
      };
      extraBackupArgs = [ "--exclude-caches" ];
    };
  };
}
