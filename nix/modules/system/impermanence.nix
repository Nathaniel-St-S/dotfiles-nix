{ username, ... }: {

  age.identityPaths = [ "/persist/etc/age/key.txt" ];

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
        ".config/waypaper"
        ".config/spotify"
        ".config/zen"
        ".cache/waypaper"
        ".cache/spotify"
        ".cache/wal"
        ".cache/zen"
        ".cache/swww"
      ];
      files = [
        ".config/zsh/.zsh_history"
        ".config/nushell/history.sqlite3"
      ];
    };
  };
}
