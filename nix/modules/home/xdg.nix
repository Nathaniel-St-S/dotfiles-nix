{ ... }: {

  xdg = {
    enable = true;
    userDirs = {
      enable            = true;
      createDirectories = true;
    };
  };
  
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html"                      = "zen-beta.desktop";
      "x-scheme-handler/http"          = "zen-beta.desktop";
      "x-scheme-handler/https"         = "zen-beta.desktop";
      "x-scheme-handler/ftp"           = "zen-beta.desktop";
      "application/xhtml+xml"          = "zen-beta.desktop";
      "application/x-extension-htm"    = "zen-beta.desktop";
      "application/x-extension-html"   = "zen-beta.desktop";
      "application/x-extension-xhtml"  = "zen-beta.desktop";
      "application/x-extension-xht"    = "zen-beta.desktop";
      # Images
      "image/jpeg"                     = "loupe";
      "image/png"                      = "loupe";
      "image/gif"                      = "loupe";
      "image/webp"                     = "loupe";
      "image/bmp"                      = "loupe";
    };
  };

  xdg.configFile."wireplumber/wireplumber.conf.d/51-default-volume.conf".text = ''
    monitor.alsa.rules = [
      {
        matches = [
          { node.name = "~alsa_output.*" }
        ]
        actions = {
          update-props = {
            node.volume = 0.0
          }
        }
      }
      {
        matches = [
          { node.name = "~alsa_input.*" }
        ]
        actions = {
          update-props = {
            node.volume = 0.0
          }
        }
      }
    ]
  '';
}
