{ ... }:
{
  programs.niri.settings.spawn-at-startup = [
    { command = [ "swww-daemon" ]; }
    { command = [ "hypridle" ]; }
    { command = [ "swaync" ]; }
    { command = [ "xwayland-satellite" ]; }
    { command = [ "sh" "-c" "clipse -listen" ]; }
    { command = [ "udiskie" ]; }
    { command = [ "generate-colors" ]; }
  ];
}
