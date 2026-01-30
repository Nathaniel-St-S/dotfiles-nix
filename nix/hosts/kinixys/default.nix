# Laptop specific configuration file
{pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "kinixys";

  # environment.systemPackages = [
  #   (pkgs.mathematica.overrideAttrs (old: {
  #     src = /home/nathaniels/Downloads/Wolfram_14.3.0_LIN.sh;
  #   }))
  # ];
}
