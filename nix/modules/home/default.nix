{ pkgs, username, autoImport, ... }: 

let
  homePrefix = if pkgs.stdenv.isDarwin then "/Users" else "/home";
in {

  imports = autoImport { path = ./.;  exclude = [ ./tmux ./kitty ]; };

  programs.home-manager.enable = true;

  home = {
    inherit username;
    homeDirectory = "${homePrefix}/${username}";
    stateVersion  = "25.11";

    sessionPath = [
      "$XDG_DATA_HOME/cargo/bin"
      "$XDG_DATA_HOME/go/bin"
      "$XDG_DATA_HOME/npm/bin"
    ];

    sessionVariables = {
      # Rust
      CARGO_HOME  = "$XDG_DATA_HOME/cargo";
      RUSTUP_HOME = "$XDG_DATA_HOME/rustup";

      # Go
      GOPATH     = "$XDG_DATA_HOME/go";
      GOCACHE    = "$XDG_CACHE_HOME/go-build";
      GOMODCACHE = "$XDG_CACHE_HOME/go-mod";

      # Python 
      PIP_CACHE_DIR   = "$XDG_CACHE_HOME/pip";
      PIP_CONFIG_FILE = "$XDG_CONFIG_HOME/pip/pip.conf";
      PIPX_HOME       = "$XDG_DATA_HOME/pipx";
      PIPX_BIN_DIR    = "$XDG_DATA_HOME/pipx/bin";

      # npm
      NPM_CONFIG_INIT_MODULE = "$XDG_CONFIG_HOME/npm/config/npm-init.js";
      NPM_CONFIG_PREFIX      = "$XDG_DATA_HOME/npm";
      NPM_CONFIG_CACHE       = "$XDG_CACHE_HOME/npm";
      NPM_CONFIG_TMP         = "$XDG_RUNTIME_DIR/npm";

      # GnuPG
      GNUPGHOME = "$XDG_DATA_HOME/gnupg";

      # Wine
      WINEPREFIX = "$XDG_DATA_HOME/wine";

      # .NET
      DOTNET_CLI_HOME = "$XDG_DATA_HOME/dotnet";

      # PulseAudio
      PULSE_COOKIE = "$XDG_CACHE_HOME/pulse/cookie";

      # Java prefs
      _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java";

      XCOMPOSECACHE = "$XDG_CACHE_HOME/compose";

      # Cursor
      XCURSOR_PATH  = "$XDG_DATA_HOME/icons:${pkgs.bibata-cursors}/share/icons";
      XCURSOR_THEME = "Bibata-Modern-Ice";
      XCURSOR_SIZE  = "24";

      # Editors
      EDITOR      = "nvim";
      VISUAL      = "nvim";
      SUDO_EDITOR = "nvim";

      # Browsers
      BROWSER = "zen-beta";
    };
  };
}
