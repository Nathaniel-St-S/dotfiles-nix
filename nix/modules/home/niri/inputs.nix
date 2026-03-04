{ ... }:
{
  programs.niri.settings.input = {
    keyboard.numlock = true;

    touchpad = {
      tap           = true;
      natural-scroll = true;
    };

    warp-mouse-to-focus.enable      = true;
    focus-follows-mouse.max-scroll-amount = "0%";
  };
}
