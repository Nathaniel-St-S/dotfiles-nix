{ username, ... }: {

  age.identityPaths = [ "/persist/etc/age/key.txt" ];

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

  systemd.tmpfiles.rules = [
    "f /persist/etc/ssh/ssh_host_ed25519_key     0600 root root -"
    "f /persist/etc/ssh/ssh_host_ed25519_key.pub 0644 root root -"
    "f /persist/etc/ssh/ssh_host_rsa_key         0600 root root -"
    "f /persist/etc/ssh/ssh_host_rsa_key.pub     0644 root root -"
    "f /persist/etc/ly/save.txt                  0644 root root -"
    "d /persist/home/${username}                  0700 ${username} users -"
    "d /persist/home/${username}/.ssh             0700 ${username} users -"
  ];

  environment.persistence."/persist" = {
    hideMounts = true;

    directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/bluetooth"
      "/var/lib/tailscale"
      "/var/lib/systemd/coredump"
      "/var/lib/nixos"
      "/var/db/sudo"
      "/var/log"
    ];

    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ly/save.txt"
    ];

    users.${username} = {
      directories = [
        "dotfiles"
        "Downloads"
        "Documents"
        "Pictures"
        { directory = ".ssh";   mode = "0700"; }
        ".local/share/zoxide"
        ".local/share/nvim"
        ".local/share/zen"
        ".local/state/nushell"
        ".local/state/nvim"
        ".local/share/tmux"
        ".config/waypaper"
        ".config/spotify"
        ".config/waybar"
        ".config/niri"
        ".config/zen"
        ".cache/swww"
        ".cache/waypaper"
        ".cache/spotify"
        ".cache/wal"
        ".cache/zen"
      ];
      files = [
        ".config/zsh/.zsh_history"
        ".config/nushell/history.sqlite3"
        ".config/nushell/history.sqlite3-shm"
        ".config/nushell/history.sqlite3-wal"
      ];
    };
  };
}
