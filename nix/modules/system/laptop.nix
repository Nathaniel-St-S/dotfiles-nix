{ pkgs, lib, ... }: {

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

  # Fingerprints
  services.fprintd.enable = true;
  security.pam.services = {
    login.fprintAuth = true;
  };
  security.pam.services.ly = {
  text = ''
    auth      sufficient    pam_unix.so try_first_pass likeauth nullok
    auth      sufficient    pam_fprintd.so
    auth      include       login
    account   include       login
    password  include       login
    session   include       login
  '';
};
  security.pam.services.hyprlock = {
    text = ''
      auth      sufficient    pam_unix.so try_first_pass likeauth nullok
      auth      sufficient    pam_fprintd.so
      auth      include       login
      account   include       login
      password  include       login
      session   include       login
    '';
  };
  security.pam.services.sudo = {
    text = ''
      auth      sufficient    pam_unix.so try_first_pass likeauth nullok
      auth      sufficient    pam_fprintd.so
      auth      include       login
      account   include       login
      password  include       login
      session   include       login
    '';
  };
}
