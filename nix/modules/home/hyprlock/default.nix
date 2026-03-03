{ pkgs, username, autoImport, ... }: {

  home.packages = with pkgs; [ hyprlock playerctl ];

  imports = autoImport { path = ./scripts; };

  programs.hyprlock = {
    enable = true;

    settings = {

      background = [
        {
          path         = "/home/${username}/.cache/current-wallpaper";
          blur_size    = 15;
          blur_passes  = 2;
          brightness   = 0.33;
        }
      ];

      input-field = [
        {
          monitor           = "";
          size              = "250, 50";
          outline_thickness = 0;
          dots_size         = 0.1;
          dots_spacing      = 0.3;
          inner_color       = "rgba(141316FF)";
          font_color        = "rgba(FFFFFFDD)";
          fade_on_empty     = true;
          position          = "0, 170";
          halign            = "center";
          valign            = "bottom";
        }
      ];

      label = [

        # Clock — Hour
        {
          monitor     = "";
          text        = ''cmd[update:1000] echo -e "$(date +"%H")"'';
          color       = "rgba(FFFFFFDD)";
          font_size   = 130;
          font_family = "Maple Mono Bold";
          position    = "0, -240";
          halign      = "center";
          valign      = "top";
        }

        # Clock — Minutes
        {
          monitor     = "";
          text        = ''cmd[update:1000] echo -e "$(date +"%M")"'';
          color       = "rgba(FFFFFFDD)";
          font_size   = 130;
          font_family = "Maple Mono Bold";
          position    = "0, -400";
          halign      = "center";
          valign      = "top";
        }

        # Date
        {
          monitor     = "";
          text        = ''cmd[update:5000] date +"%A, %B %d"'';
          color       = "rgba(FFFFFFDD)";
          font_size   = 24;
          font_family = "Pacifico Regular";
          position    = "0, -80";
          halign      = "center";
          valign      = "center";
        }

        # Now playing
        {
          monitor     = "";
          text        = ''cmd[update:1000] echo "$(hyprlock-song-details)"'';
          color       = "rgba(255, 255, 255, 0.6)";
          font_size   = 18;
          font_family = "Maple Mono Bold";
          position    = "0, 100";
          halign      = "center";
          valign      = "bottom";
        }

        # Battery / system info
        {
          monitor     = "";
          text        = ''cmd[update:1000] echo -e "$(hyprlock-battery-info)"'';
          color       = "rgba(255, 255, 255, 1)";
          font_size   = 18;
          font_family = "Pacifico Regular";
          position    = "-20, -560";
          halign      = "right";
          valign      = "center";
        }

      ];
    };
  };
}
