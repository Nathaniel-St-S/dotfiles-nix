{ ... }: {
  programs.nix-index-database.comma.enable = true;
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };
}
