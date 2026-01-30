{ pkgs, ... }: {

  home.packages = with pkgs; [ hypridle brightnessctl libnotify ];

  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd          = "pidof hyprlock || hyprlock";
        before_sleep_cmd  = "loginctl lock-session";
        after_sleep_cmd   = "niri msg action power-on-monitors";
      };

      listener = [
        # Dim screen after 2.5 min
        {
          timeout    = 150;
          on-timeout = "brightnessctl -s set 10";
          on-resume  = "brightnessctl -r";
        }

        # Turn off display after 3 min
        {
          timeout    = 180;
          on-timeout = "niri msg action power-off-monitors";
          on-resume  = "niri msg action power-on-monitors && brightnessctl -r";
        }

        # Kill keyboard backlight after 3 min
        {
          timeout    = 180;
          on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0";
          on-resume  = "brightnessctl -rd rgb:kbd_backlight";
        }

        # Lock screen after 5 min
        {
          timeout    = 300;
          on-timeout = "loginctl lock-session";
          on-resume  = ''notify-send "Welcome back"'';
        }

        # Suspend after 10 min
        {
          timeout    = 600;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
