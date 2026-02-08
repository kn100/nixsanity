{ lib, config, ... }:

{

  sops.secrets.mqtt_password = { };
  sops.templates.z2m_secrets = {
    owner = "zigbee2mqtt";
    content = "ZIGBEE2MQTT_CONFIG_MQTT_PASSWORD=${config.sops.placeholder.mqtt_password}";
  };

  systemd.services.zigbee2mqtt.serviceConfig.EnvironmentFile = config.sops.templates.z2m_secrets.path;

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      homeassistant = lib.mkForce true;
      permit_join = false;
      mqtt = {
        base_topic = "zigbee2mqtt";
        server = "mqtt://localhost:1883";
        user = "mqttuser";
      };
      serial = {
        port = "/dev/ttyUSB0";
      };
      frontend = {
        port = 8080;
      };
      advanced = {
        channel = 25;
        log_level = "info";
      };
      availability = true;
      ota = {
        default_maximum_data_size = 100;
        image_block_response_delay = 50;
      };
      devices = {
        "0xdc8e95fffe57e08f".friendly_name = "Office Lamp";
        "0xf082c0fffe30ca39".friendly_name = "LR Lamp";
        "0xa4c1389677c54872" = {
          friendly_name = "knobby";
          homeassistant.name = "knobby";
          legacy = false;
          optimistic = true;
        };
        "0xa4c138dc2e0c880f" = {
          friendly_name = "Bar Beam Light";
          transition = 0;
          homeassistant.name = "beamlight";
          legacy = false;
          optimistic = true;
        };
        "0x6cfd22fffe1ca939".friendly_name = "wcl1";
        "0x6cfd22fffe2d5ad3".friendly_name = "wcl2";
        "0x6cfd22fffe1a3213".friendly_name = "wcl8";
        "0x6cfd22fffe1ce784".friendly_name = "wcl6";
        "0x8c65a3fffe707540".friendly_name = "wcl4";
        "0x6cfd22fffe1ceb74".friendly_name = "wcl7";
        "0x6cfd22fffe1bfb42".friendly_name = "wcl5";
        "0x6cfd22fffe1c88d0".friendly_name = "wcl3";
        "0x70b3d52b6002cc01".friendly_name = "Steamer plug";
        "0x70b3d52b6003130f".friendly_name = "3dprinter";
        "0x881a14fffe207503".friendly_name = "Bathroom Styrbar";
        "0x187a3efffefabf23".friendly_name = "Living Room 4 Gang Switch";
        "0x403059fffe1b942c".friendly_name = "Silver bottom";
        "0xd44867fffe8989db".friendly_name = "Silver top";
        "0x403059fffe1b9305".friendly_name = "Silver middle";
        "0x70b3d52b6002c890".friendly_name = "Bike";
        "0x44e2f8fffe037510".friendly_name = "dumbassstyrbar";
      };
      groups = {
        "1".friendly_name = "wcl";
        "2".friendly_name = "silver lamp";
        "3".friendly_name = "office floorlamo";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
}
