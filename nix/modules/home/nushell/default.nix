{ config, pkgs, autoImport, ... }:

let
  dataDir   = config.xdg.dataHome;
  cacheDir  = config.xdg.cacheHome;
  configDir = config.xdg.configHome;
  homeDir   = config.home.homeDirectory;
in
{
  # ─────────────────────────────────────────────────────────────────────────────
  # Packages
  # ─────────────────────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    zoxide
    fzf
    bat
    tree
    ffmpeg
  ];

  imports = autoImport { path = ./.; };

  # ─────────────────────────────────────────────────────────────────────────────
  # Nushell
  # ─────────────────────────────────────────────────────────────────────────────
  programs.nushell = {
    enable = true;

    # ── env.nu ────────────────────────────────────────────────────────────────
    extraEnv = ''
      # ── Rust ────────────────────────────────────────────────────────────────
      $env.CARGO_HOME  = "${dataDir}/cargo"
      $env.RUSTUP_HOME = "${dataDir}/rustup"

      # ── Go ──────────────────────────────────────────────────────────────────
      $env.GOPATH      = "${dataDir}/go"
      $env.GOCACHE     = "${cacheDir}/go-build"
      $env.GOMODCACHE  = "${cacheDir}/go-mod"

      # ── Python ──────────────────────────────────────────────────────────────
      $env.PIP_CACHE_DIR   = "${cacheDir}/pip"
      $env.PIP_CONFIG_FILE = "${configDir}/pip/pip.conf"
      $env.PIPX_HOME       = "${dataDir}/pipx"
      $env.PIPX_BIN_DIR    = "${dataDir}/pipx/bin"

      # ── NPM ─────────────────────────────────────────────────────────────────
      $env.NPM_CONFIG_INIT_MODULE = "${configDir}/npm/config/npm-init.js"
      $env.NPM_CONFIG_PREFIX      = "${dataDir}/npm"
      $env.NPM_CONFIG_CACHE       = "${cacheDir}/npm"
      $env.NPM_CONFIG_TMP         = ($env.XDG_RUNTIME_DIR? | default "/tmp" | path join "npm")

      # ── Java ────────────────────────────────────────────────────────────────
      $env._JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${configDir}/java"

      # ── Misc XDG ────────────────────────────────────────────────────────────
      $env.GNUPGHOME       = "${dataDir}/gnupg"
      $env.WINEPREFIX      = "${dataDir}/wine"
      $env.GTK2_RC_FILES   = "${configDir}/gtk-2.0/gtkrc"
      $env.DOTNET_CLI_HOME = "${dataDir}/dotnet"
      $env.PULSE_COOKIE    = "${cacheDir}/pulse/cookie"
      $env.XCOMPOSECACHE   = "${cacheDir}/compose"

      # ── Cursor ──────────────────────────────────────────────────────────────
      $env.XCURSOR_THEME = "Bibata-Modern-Ice"
      $env.XCURSOR_SIZE  = "24"

      # ── Editors ─────────────────────────────────────────────────────────────
      $env.EDITOR      = "nvim"
      $env.VISUAL      = "nvim"
      $env.SUDO_EDITOR = "nvim"

      # ── Zoxide ──────────────────────────────────────────────────────────────
      $env._ZO_DATA_DIR = "${dataDir}/zoxide"

      # ── Bat ─────────────────────────────────────────────────────────────────
      $env.BAT_THEME = "ansi"

      # ── PATH ────────────────────────────────────────────────────────────────
      $env.PATH = ($env.PATH | split row (char esep) | prepend [
        "${homeDir}/.local/bin"
        "${dataDir}/cargo/bin"
        "${dataDir}/go/bin"
        "${dataDir}/npm/bin"
        "${dataDir}/pipx/bin"
      ] | uniq)
    '';

    # ── config.nu ─────────────────────────────────────────────────────────────
    extraConfig = ''
      # ── Pywal colour restoration ─────────────────────────────────────────────
      if ("${cacheDir}/wal/sequences" | path exists) {
        cat "${cacheDir}/wal/sequences"
        $env.LS_COLORS = "di=1;34:fi=1;37:ln=1;36:pi=40;33:so=1;35:bd=40;33;1:cd=40;33;1:or=40;31;1:mi=0:ex=1;32"
      }

      # ── Core config ──────────────────────────────────────────────────────────
      $env.config = {
        show_banner: false

        completions: {
          case_sensitive: false
          quick:          true
          partial:        true
          algorithm:      "fuzzy"
        }

        history: {
          max_size:     100_000
          sync_on_enter: true
          file_format:  "sqlite"
          isolation:    false
        }

        edit_mode: vi
        cursor_shape: {
          vi_insert: line
          vi_normal: block
        }

        color_config: {
          separator:                   white
          leading_trailing_space_bg:   { attr: n }
          header:                      green_bold
          empty:                       blue
          bool:                        white
          int:                         white
          filesize:                    cyan
          duration:                    white
          date:                        purple
          range:                       white
          float:                       white
          string:                      white
          nothing:                     white
          binary:                      white
          cellpath:                    white
          row_index:                   green_bold
          record:                      white
          list:                        white
          block:                       white
          hints:                       dark_gray
        }

        buffer_editor: "nvim"
      }
    '';
  };
}
