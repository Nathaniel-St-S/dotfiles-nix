{ pkgs, ... }: {

  home.packages = with pkgs; [
    (graphite-gtk-theme.override {
      themeVariants = [ "default" ];
      colorVariants  = [ "dark" ];
    })
    papirus-icon-theme
    adwaita-qt
  ];

  # ── GTK3 settings ───────────────────────
  xdg.configFile."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Graphite-Dark
    gtk-icon-theme-name=Papirus-Dark
    gtk-cursor-theme-name=Bibata-Modern-Ice
    gtk-cursor-theme-size=24
    gtk-font-name=Rubik 11
    gtk-application-prefer-dark-theme=1
    gtk-decoration-layout=close,maximize,minimize:menu
  '';

  # ── GTK4 settings ─────────────────────────────────────────────────────────
  xdg.configFile."gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Graphite-Dark
    gtk-icon-theme-name=Papirus-Dark
    gtk-cursor-theme-name=Bibata-Modern-Ice
    gtk-cursor-theme-size=24
    gtk-font-name=Rubik 11
    gtk-application-prefer-dark-theme=1
  '';

  # ── dconf / GSettings ──────────────────
  dconf.settings."org/gnome/desktop/interface" = {
    gtk-theme    = "Graphite-Dark";
    icon-theme   = "Papirus-Dark";
    cursor-theme = "Bibata-Modern-Ice";
    cursor-size  = 24;
    color-scheme = "prefer-dark";
    font-name    = "Rubik 11";
  };

  # ── Qt ────────────────────────────────────────────────────────────────────
  qt = {
    enable             = true;
    platformTheme.name = "gtk";
    style = {
      package = pkgs.adwaita-qt;
      name    = "adwaita-dark";
    };
  };

  # ── Environment ───────────────────────────────────────────────────────────
  home.sessionVariables = {
    GTK_THEME            = "Graphite-Dark";
    QT_QPA_PLATFORMTHEME = "gtk2";
    QT_STYLE_OVERRIDE    = "adwaita-dark";
  };
}

