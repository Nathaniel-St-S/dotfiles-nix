# Laptop specific configuration file
{pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "kinixys";

  boot.initrd.systemd.enable = true;

  boot.initrd.systemd.services.rollback = {
    description = "Rollback btrfs root to blank snapshot";
    wantedBy    = [ "initrd.target" ];
    after       = [ "initrd-root-device.target" ];
    before      = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /btrfs_tmp
      mount -t btrfs -o subvol=/ /dev/disk/by-uuid/f8fc5ea4-f5ca-45f5-a234-2d65ccf3deef /btrfs_tmp
      delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
          delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
      }
      delete_subvolume_recursively /btrfs_tmp/@
      btrfs subvolume snapshot /btrfs_tmp/@blank /btrfs_tmp/@
      umount /btrfs_tmp
    '';
  };

  # environment.systemPackages = [
  #   (pkgs.mathematica.overrideAttrs (old: {
  #     src = /home/nathaniels/Downloads/Wolfram_14.3.0_LIN.sh;
  #   }))
  # ];
}
