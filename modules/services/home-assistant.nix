{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "default_config"
      "met"
      "esphome"
      "mqtt"
      "zha"
      "wled"
      "cast"
      "vesync"
      "androidtv_remote"
      "telegram_bot"
      "radio_browser"
    ];
    config = {
      http = {
        trusted_proxies = [
          "127.0.0.1"
          "::1"
          "100.64.0.0/10"
        ];
        use_x_forwarded_for = true;
      };

      # Import our JSON-converted configurations
      automation = lib.importJSON ./home-assistant/automations.json;
      scene = lib.importJSON ./home-assistant/scenes.json;
      script = lib.importJSON ./home-assistant/scripts.json;
    };
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
}
