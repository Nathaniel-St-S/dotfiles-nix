{ ... }: {

  # Laptop-specific hardware and power management
  services.power-profiles-daemon.enable = false;

  services.tlp ={ 
    enable = true;
    settings = {
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "off";
    };
  };

  services.thermald.enable = true;

  # Lid switch handling
  services.logind.settings.Login = {
    HandleLidSwitch             = "suspend";
    HandleLidSwitchExternalPower = "suspend";
  };

  # Wifi settings
  networking.networkmanager.wifi.backend = "wpa_supplicant";
}
