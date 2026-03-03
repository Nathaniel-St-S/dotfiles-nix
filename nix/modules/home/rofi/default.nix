{ pkgs, autoImport, ... }:

{
  imports = autoImport { path = ./.; };

  programs.rofi = {
    enable  = true;
    package = pkgs.rofi;

    font = "Rubik 12";

    extraConfig = {
      modi                = "drun,run";
      show-icons          = false;
      display-drun        = "";
      display-run         = "";
      display-filebrowser = "";
      display-window      = "";
      drun-display-format = "{name}";
      window-format       = "{w} · {c} · {t}";
    };
  };
}

