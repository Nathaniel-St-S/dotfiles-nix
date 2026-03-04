{ ... }: {

  # Laptop-specific hardware and power management
  services.tlp.enable = true;

  powerManagement = {
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  # Lid switch handling
  services.logind.settings.Login = {
    HandleLidSwitch             = "suspend";
    HandleLidSwitchExternalPower = "suspend";
  };

  # Backlight control
  programs.light.enable = true;

  # Wifi settings
  networking.networkmanager.wifi.backend = "wpa_supplicant";
}
