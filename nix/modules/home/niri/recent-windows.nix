{ ... }:
{
  programs.niri.settings.recent-windows = {
    open-delay-ms = 100;
    highlight = {
      padding       = 20;
      corner-radius = 4;
    };
    previews = {
      max-height = 1080;
      max-scale  = 0.75;
    };
  };
}
