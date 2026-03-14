{ config, pkgs, autoImport, ... }:{

  home.packages = with pkgs; [ ghostty pywal ];

  imports = autoImport { path = ./.; };

  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "Maple Mono NF";
      font-family-bold = "Maple Mono NF Bold";
      font-family-italic = "Maple Mono NF Italic";
      font-family-bold-italic = "Maple Mono NF Bold Italic";
      font-size = 15;

      scrollback-limit = 2000;
      background-opacity = 0.8;
      background-blur = 1;

      window-padding-x = 0;
      window-padding-y = 0;
      window-padding-balance = true;

      notify-on-command-finish = "unfocused";
      notify-on-command-finish-action = "no-bell,notify";

      adjust-cell-height = 1;

      custom-shader = "cursor_smear.glsl";

      config-file = "${config.home.homeDirectory}/.cache/wal/ghostty.conf";

      # Keynbinds
      keybind = "ctrl+enter=unbind";
    };
  };
}
