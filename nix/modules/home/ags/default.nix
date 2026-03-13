{ inputs, pkgs, ... }: {
  imports = [ inputs.ags.homeManagerModules.default ];

  programs.ags = {
    enable = true;

    # Symlinks the config dir to ~/.config/ags
    configDir = ./config;

    # Astal libraries + any executables made available to the GJS runtime
    extraPackages = with pkgs; [
      inputs.astal.packages.${pkgs.system}.battery
      inputs.astal.packages.${pkgs.system}.wireplumber
      inputs.astal.packages.${pkgs.system}.bluetooth
      inputs.astal.packages.${pkgs.system}.network
      inputs.astal.packages.${pkgs.system}.tray
      inputs.astal.packages.${pkgs.system}.mpris
      playerctl
    ];
  };
}
