{ pkgs, autoImport, ... }:
{
  imports = autoImport { path = ./.; exclude = [ ./recent-windows.nix ]; };

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
    settings = {
      prefer-no-csd = true;
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
      cursor = {
        theme                  = "Bibata-Modern-Ice";
        size                   = 24;
        hide-when-typing       = true;
        hide-after-inactive-ms = 1000;
      };
      gestures.hot-corners.enable  = false;
      overview.workspace-shadow.enable = false;
      hotkey-overlay.skip-at-startup   = true;
    };
  };

  home.packages = with pkgs; [
    wl-clipboard
    clipse
    swww
    udiskie
    xwayland-satellite
    playerctl
    brightnessctl
  ];
}
