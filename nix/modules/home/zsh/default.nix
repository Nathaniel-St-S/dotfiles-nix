{ config, pkgs, autoImport, ... }:

{
  home.sessionVariables = {
    ZDOTDIR     = "$HOME/.config/zsh";
  };

  imports = autoImport { path = ./.; };

  home.packages = with pkgs; [
    zoxide
    fzf
    bat
    tree
    ffmpeg
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
  };
}

