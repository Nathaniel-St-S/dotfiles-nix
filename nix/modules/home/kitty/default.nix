{ pkgs, ... }:

{
  home.packages = with pkgs; [ kitty pywal ];

  programs.kitty = {
    enable = true;
    font = {
      package = pkgs.maple-mono.NF-CN-unhinted;
      name = "Maple Mono NF CN";
      size = 15;
    };
    settings = {
      cursor_trail = 10;
      cursor_trail_start_threshold = 0;
      scrollback_lines = 2000;
      scrollback_pager_history_size = 10;
      tab_bar_style = "fade";
      background_blur = 1;
    };
    extraConfig = ''
      notify_on_cmd_finish unfocused 10
      cursor_trail_decay 0.1 0.5
      include ~/.cache/wal/colors-kitty.conf
      background_opacity 0.8
    '';
  };

}

