{ pkgs, inputs, config, username, ... }: {

  # Bootloader
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      # Hide the OS choice for bootloaders.
      # It's still possible to open the bootloader list by pressing any key
      # It will just not appear on screen unless a key is pressed
      timeout = 0;
    };

    # plymouth themes to use
    #   angular_alt
    #   colorful
    #   cuts
    #   lone
    #   loader_2
    #   loader_alt
    #   rings
    plymouth = {
      enable = true;
      theme = "lone";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "lone" ];
        })
      ];
    };

    # Use latest kernel image
    kernelPackages = pkgs.linuxPackages_latest;

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
    ];
  };

  time.timeZone      = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # :)
  security.sudo.extraConfig = ''
    Defaults insults
  '';

  # NUR and Lix
  nixpkgs.overlays = [
    inputs.nur.overlays.default
    inputs.niri.overlays.niri
    (final: prev: {
     inherit (prev.lixPackageSets.latest) nixpkgs-review nix-eval-jobs nix-fast-build colmena;
     })
  ];

  # Packages
  nixpkgs.config.allowUnfree = true; 
  nix.package = pkgs.lixPackageSets.latest.lix;
  environment.systemPackages = with pkgs; 
    let
      sddm-theme = pkgs.sddm-astronaut.override { embeddedTheme = "pixel_sakura"; };
    in
    [
    #Core Utils
    gnumake pciutils
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Nice to haves
    sioyek loupe

    # Compression tools
    zip unzip

    # Programming languages
    zig typst rustc cargo
    clippy rustfmt racket
    python315

    # For Sddm
    sddm-theme
    kdePackages.qtmultimedia

  ];
  # Sync local spotify tracks with phones and other devices on my network
  # networking.firewall.allowedTCPPorts = [ 57621 ];
  # Enable spotify to be discovered by other devices
  # networking.firewall.allowedUDPPorts = [ 5353 ];

  programs.dconf.enable = true;

  programs.nh = {
    enable = true;
    flake = "${config.users.users.${username}.home}/dotfiles";
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 3";
    };
  };

  hardware.enableRedistributableFirmware = true;
  # Networking
  networking.networkmanager.enable = true;

  # User
  users.users.${username} = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets."${config.networking.hostName}-password".path;
    shell        = pkgs.zsh;
    extraGroups  = [ "wheel" "networkmanager" "audio" "video" "input" "keyd" ];
  };


  # Shell
  programs.zsh = {
    enable = true;
    shellInit = ''
      export ZDOTDIR="$HOME/.config/zsh"
    '';
  };

  # Audio — pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable      = true;
  services.pipewire = {
    enable             = true;
    alsa.enable        = true;
    alsa.support32Bit  = true;
    pulse.enable       = true;
    wireplumber.enable = true;
  };

  services.printing.enable = true;
  services.udisks2.enable = true;

  # Bluetooth
  hardware.bluetooth = {
    enable      = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    package = pkgs.kdePackages.sddm;
    extraPackages = 
      let
      theme = pkgs.sddm-astronaut.override { embeddedTheme = "pixel_sakura"; };
      in 
      [ theme pkgs.kdePackages.qtmultimedia ];
  };

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        main = {
          capslock = "overload(control, esc)";
          tab      = "overload(meta, tab)";
        };
        "shift:S" = {
          space    = "delete";
          capslock = "capslock";
        };
        "meta+alt" = {
          r = "command(systemctl reboot)";
          s = "command(systemctl suspend)";
          p = "command(systemctl poweroff)";
        };
      };
    };
  };

  # SSH
  services.seatd.enable = true;
  services.openssh = {
    enable = true;
    allowSFTP = false;
    ports = [2227];
    authorizedKeysInHomedir = true;
    settings = {
      PasswordAuthentication = false;
      PermitEmptyPasswords = false;
      PubkeyAuthentication = true;
      PermitRootLogin = "no";
      LoginGraceTime = 30;

      KbdInteractiveAuthentication = false;
      Compression = true;

      X11Forwarding = false;
      AllowTCPForwarding = false;
      AllowUsers = ["nathaniels"];

      MaxAuthTries = 3;
      MaxSessions = 10;
      ClientAliveInterval = 120;
      ClientAliveCountMax = 10;
    };
  };

  # Firewall
  networking.firewall.enable = true;

  # Tailscale
  services.tailscale.enable = true;

  services.displayManager.sessionPackages = [ pkgs.niri-unstable ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      maple-mono.NF-CN-unhinted
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      fira-sans
      fira-code
      font-awesome
      rubik
      roboto
      (google-fonts.override { fonts = [ "Pacifico" ]; })
      dejavu_fonts
      liberation_ttf
    ];
    fontconfig.defaultFonts = {
      monospace = [ "Maple Mono NF CN" ];
      sansSerif = [ "Rubik" ];
    };
  };

  # XDG portal
  xdg.portal = {
    enable       = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # Polkit
  security.polkit.enable = true;

  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://niri.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];

    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store   = true;

    max-jobs = "auto";
    cores = 0;

    narinfo-cache-negative-ttl = 3600;

    connect-timeout = 5;
  };

  system.stateVersion = "25.11";
}
