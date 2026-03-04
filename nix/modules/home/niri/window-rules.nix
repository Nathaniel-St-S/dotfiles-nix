{ ... }:
{
  programs.niri.settings.window-rules = [
    {
      geometry-corner-radius = {
        top-left     = 4.0;
        top-right    = 4.0;
        bottom-left  = 4.0;
        bottom-right = 4.0;
      };
      clip-to-geometry = true;
    }
    {
      matches = [{ app-id = "^popup.term$"; }];
      open-floating               = true;
      default-column-width.proportion = 0.8;
      default-window-height.proportion = 0.8;
      draw-border-with-background = false;
    }
    {
      matches = [{ app-id = "^com.mitchellh.ghostty$"; }];
      default-column-width.proportion = 1.0;
    }
  ];

  programs.niri.settings.layer-rules = [
    {
      matches = [{ namespace = "^swww-daemon$"; }];
      place-within-backdrop = true;
    }
  ];
}
