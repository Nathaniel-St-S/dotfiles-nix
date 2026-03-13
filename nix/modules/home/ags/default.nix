{ inputs, pkgs, ... }:{
  # add the home manager module
  imports = [ inputs.ags.homeManagerModules.default ];

  # add the astal cli
  home.packages = [ inputs.astal.packages.${pkgs.system}.notifd ];

  programs.ags = {
    enable = true;

    # symlink to ~/.config/ags
    configDir = ./config;

    # additional packages and executables to add to gjs's runtime
    extraPackages = with pkgs; [
      inputs.astal.packages.${pkgs.system}.battery
      fzf
    ];
  };
}
