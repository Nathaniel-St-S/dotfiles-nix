# Desktop specific configuration file
{ ... }: {
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "sinixt";
}
