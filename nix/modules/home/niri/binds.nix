{ ... }:
{
  programs.niri.settings.binds = {
    # Apps
    "Mod+Return".action.spawn = [ "ghostty" "-e" "nu" ];
    "Mod+Alt+Return".action.spawn = [ "ghostty" ];
    "Mod+B".action.spawn = [ "zen-beta" ];
    "Mod+Alt+X".action.spawn = [ "hyprlock" ];
    "Mod+Shift+w".action.spawn = [ "waypaper" ];
    "Mod+Alt+W".action.spawn = [ "random-wallpaper" ];
    "Mod+S".action.spawn-sh = [ "spotify --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland %U" ];
    "Mod+W".action.spawn-sh = [ "pkill waybar || waybar" ];
    "Mod+V".action.spawn-sh = [ "ghostty --class=popup.term -e clipse" ];
    "Mod+E".action.spawn-sh = [ "killall spf || ghostty --class=popup.term -e spf" ];
    "Mod+Space".action.spawn-sh = [ "rofi -show drun || pkill rofi" ];

    # WM actions
    "Mod+O" = { action.toggle-overview = {}; repeat = false; };
    "Mod+Q" = { action.close-window = {}; repeat = false; };
    "Mod+Shift+X".action.quit = {};
    "Mod+Shift+P".action.power-off-monitors = {};
    "Mod+Escape" = { action.toggle-keyboard-shortcuts-inhibit = {};  allow-inhibiting = false; };

    # Focus
    "Mod+H".action.focus-column-left = {};
    "Mod+J".action.focus-window-or-workspace-down = {};
    "Mod+K".action.focus-window-or-workspace-up = {};
    "Mod+L".action.focus-column-right = {};
    "Mod+I".action.focus-column-first = {};
    "Mod+A".action.focus-column-last = {};
    "Mod+D".action.focus-workspace-down = {};
    "Mod+U".action.focus-workspace-up = {};
    "Mod+Tab".action.focus-workspace-previous = {};

    "Mod+Ctrl+H".action.focus-monitor-left = {};
    "Mod+Ctrl+J".action.focus-monitor-down = {};
    "Mod+Ctrl+K".action.focus-monitor-up = {};
    "Mod+Ctrl+L".action.focus-monitor-right = {};

    # Move
    "Mod+Shift+H".action.move-column-left-or-to-monitor-left = {};
    "Mod+Shift+J".action.move-window-down-or-to-workspace-down = {};
    "Mod+Shift+K".action.move-window-up-or-to-workspace-up = {};
    "Mod+Shift+L".action.move-column-right-or-to-monitor-right = {};
    "Mod+Shift+I".action.move-column-to-first = {};
    "Mod+Shift+A".action.move-column-to-last = {};
    "Mod+Shift+D".action.move-column-to-workspace-down = {};
    "Mod+Shift+U".action.move-column-to-workspace-up = {};
    "Mod+Ctrl+D".action.move-workspace-down = {};
    "Mod+Ctrl+U".action.move-workspace-up = {};

    # Workspaces
    "Mod+1".action.focus-workspace = 1;
    "Mod+2".action.focus-workspace = 2;
    "Mod+3".action.focus-workspace = 3;
    "Mod+4".action.focus-workspace = 4;
    "Mod+5".action.focus-workspace = 5;
    "Mod+6".action.focus-workspace = 6;
    "Mod+7".action.focus-workspace = 7;
    "Mod+8".action.focus-workspace = 8;
    "Mod+9".action.focus-workspace = 9;
    "Mod+Ctrl+1".action.move-column-to-workspace = 1;
    "Mod+Ctrl+2".action.move-column-to-workspace = 2;
    "Mod+Ctrl+3".action.move-column-to-workspace = 3;
    "Mod+Ctrl+4".action.move-column-to-workspace = 4;
    "Mod+Ctrl+5".action.move-column-to-workspace = 5;
    "Mod+Ctrl+6".action.move-column-to-workspace = 6;
    "Mod+Ctrl+7".action.move-column-to-workspace = 7;
    "Mod+Ctrl+8".action.move-column-to-workspace = 8;
    "Mod+Ctrl+9".action.move-column-to-workspace = 9;

    # Column / window sizing
    "Mod+BracketLeft".action.consume-or-expel-window-left = {};
    "Mod+BracketRight".action.consume-or-expel-window-right = {};
    "Mod+Comma".action.consume-window-into-column = {};
    "Mod+Period".action.expel-window-from-column = {};
    "Mod+R".action.switch-preset-column-width = {};
    "Mod+Alt+R".action.switch-preset-column-width-back = {};
    "Mod+Shift+R".action.switch-preset-window-height = {};
    "Mod+Ctrl+R".action.reset-window-height = {};
    "Mod+M".action.maximize-column = {};
    "Mod+F".action.expand-column-to-available-width = {};
    "Mod+C".action.center-column = {};
    "Mod+Ctrl+C".action.center-visible-columns = {};
    "f11".action.fullscreen-window = {};
    "Mod+Minus".action.set-column-width = "-10%";
    "Mod+Equal".action.set-column-width = "+10%";
    "Mod+Shift+Minus".action.set-window-height = "-10%";
    "Mod+Shift+Equal".action.set-window-height = "+10%";
    "Mod+Shift+F".action.toggle-window-floating = {};
    "Mod+Alt+F".action.switch-focus-between-floating-and-tiling = {};
    "Mod+Alt+B".action.toggle-column-tabbed-display = {};

    # Screenshots
    "Print".action.screenshot = {};
    "Ctrl+Print".action.screenshot-screen  = {};
    "Alt+Print".action.screenshot-window   = {};

    # Media / hardware
    "XF86AudioRaiseVolume" = { action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";  allow-when-locked = true; };
    "XF86AudioLowerVolume" = { action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";  allow-when-locked = true; };
    "XF86AudioMute"        = { action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";  allow-when-locked = true; };
    "XF86AudioMicMute"     = { action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; allow-when-locked = true; };
    "XF86MonBrightnessUp"  = { action.spawn  = [ "brightnessctl" "--class=backlight" "set" "+5%" ];  allow-when-locked = true; };
    "XF86MonBrightnessDown" = { action.spawn = [ "brightnessctl" "--class=backlight" "set" "5%-" ]; allow-when-locked = true; };
    "XF86AudioPlay".action.spawn-sh = "playerctl play-pause";
    "XF86AudioNext".action.spawn-sh = "playerctl next";
    "XF86AudioPrev".action.spawn-sh = "playerctl previous";
    "Mod+TouchpadScrollDown".action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02+";
    "Mod+TouchpadScrollUp".action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02-";
    "Mod+Alt+J".action.spawn-sh = "playerctl previous";
    "Mod+Alt+K".action.spawn-sh = "playerctl play-pause";
    "Mod+Alt+L".action.spawn-sh = "playerctl next";
  };
}
