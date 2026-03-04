{ ... }:
{
  programs.niri.settings = {
    layout = {
      gaps                  = 2;
      center-focused-column = "never";
      background-color = "transparent";

      preset-column-widths = [
        { proportion = 0.25; }
        { proportion = 0.5;  }
        { proportion = 0.75; }
        { proportion = 1.0;  }
      ];

      default-column-width = {};

      focus-ring = {
        enable         = false;
        width          = 2;
        inactive = { color = "#505050"; };
      };

      border = {
        enable         = true;
        width          = 2;
        inactive = { color = "#505050"; };
        urgent   = { color = "#9b0000"; };
      };

      shadow = {
        enable   = true;
        softness = 30;
        spread   = 5;
        offset   = { x = 0; y = 5; };
        color    = "#0007";
      };
    };

    animations = {
      slowdown = 1.5;
      window-open.kind.spring        = { damping-ratio = 1.0; stiffness = 700; epsilon = 0.0001; };
      window-close.kind.spring       = { damping-ratio = 1.0; stiffness = 400; epsilon = 0.0001; };
      window-movement.kind.spring    = { damping-ratio = 1.0; stiffness = 200; epsilon = 0.0001; };
      overview-open-close.kind.spring = { damping-ratio = 1.0; stiffness = 900; epsilon = 0.0001; };
    };
  };
}
