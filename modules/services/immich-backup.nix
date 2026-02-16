{ config, pkgs, ... }:

{
  sops.secrets.restic_b2_account_id = {
    owner = "immich";
  };
  sops.secrets.restic_b2_account_key = {
    owner = "immich";
  };
  sops.secrets.restic_password = {
    owner = "immich";
  };

  sops.templates.restic_b2_env = {
    owner = "immich";
    content = ''
      B2_ACCOUNT_ID=${config.sops.placeholder.restic_b2_account_id}
      B2_ACCOUNT_KEY=${config.sops.placeholder.restic_b2_account_key}
    '';
  };

  # Wrapper script for convenient manual restic operations
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "restic-b2" ''
      set -euo pipefail
      if [ "$(id -u)" -ne 0 ]; then
        echo "Error: restic-b2 must be run as root (use sudo)." >&2
        exit 1
      fi
      export $(cat ${config.sops.templates.restic_b2_env.path} | xargs)
      exec ${pkgs.restic}/bin/restic -p ${config.sops.secrets.restic_password.path} "$@"
    '')
  ];

  services.restic.backups = {
    immich-new-library = {
      user = "immich";
      repository = "b2:postnix-library";
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
      pruneOpts = [
        "--keep-daily=7"
        "--keep-weekly=4"
        "--keep-monthly=3"
      ];
      extraBackupArgs = [ "--exclude-caches" ];
    };

    immich-old-library = {
      user = "immich";
      repository = "b2:prenix-library";
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
      pruneOpts = [
        "--keep-daily=7"
        "--keep-weekly=4"
        "--keep-monthly=3"
      ];
      extraBackupArgs = [ "--exclude-caches" ];
    };
  };
}
