{ config, ... }:

{

  sops.secrets.hashed_mqtt_password = {
    owner = "mosquitto";
  };

  services.mosquitto = {
    enable = true;
    persistence = true;
    listeners = [
      {
        address = "0.0.0.0";
        port = 1883;
        users.mqttuser = {
          acl = [ "readwrite #" ];
          hashedPasswordFile = config.sops.secrets.hashed_mqtt_password.path;
        };
        settings = {
          allow_anonymous = false;
        };
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ 1883 ];
}
