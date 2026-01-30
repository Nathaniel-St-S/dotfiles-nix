{ pkgs, ... }: {

  imports = [
    ./colors.nix
  ];

  home.packages = with pkgs; [
    # Wayland utilities
    wl-clipboard
    clipse
    swww
    udiskie
    xwayland-satellite
    playerctl
    brightnessctl
  ];

  home.file = {
    ".config/niri/config.kdl".source    = ./config.kdl;
    ".config/niri/binds.kdl".source     = ./binds.kdl;
    ".config/niri/outputs.kdl".source   = ./outputs.kdl;
    ".config/niri/startup.kdl".source   = ./startup.kdl;
  };

}

