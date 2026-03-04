{ pkgs, ... }:

let
  generate-colors = pkgs.writeShellApplication {
    name = "generate-colors";
    runtimeInputs = with pkgs; [
      coreutils
      swww
      pywal
    ];
    text = /* bash */ ''
      log=/tmp/waypaper-post.log
      exec >> "$log" 2>&1
      echo "POST-COMMAND CALLED at $(date)"
      echo "Argument received: ''${1:-}'"

      # Waypaper doesn't reliably pass the wallpaper as $1 — read from config.
      WALLPAPER=$(grep "^wallpaper = " "''${XDG_CONFIG_HOME:-$HOME/.config}/waypaper/config.ini" | cut -d' ' -f3)
      WALLPAPER="''${WALLPAPER/#\~/$HOME}"
      echo "Using wallpaper from config: $WALLPAPER"

      if [ ! -f "$WALLPAPER" ]; then
          echo "ERROR: Wallpaper file not found: $WALLPAPER"
          exit 1
      fi

      # ── Pywal ────────────────────────────────────────────────────────────────
      echo "Running pywal..."
      wal -i "$WALLPAPER" -n -q
      ln -sf "$(cat "''${XDG_CACHE_HOME:-$HOME/.cache}/wal/wal")" "''${XDG_CACHE_HOME:-$HOME/.cache}/current-wallpaper"

      echo "Generating waybar colors..."
      waybar-generate-colors

      echo "Generating rofi colors..."
      rofi-generate-colors

      echo "Reloading niri colors..."
      niri-generate-colors

      echo "Updating btop colors..."
      btop-generate-colors

      echo "Reloading swaync..."
      swaync-generate-colors
      swaync-client --reload-config
      swaync-client --reload-css

      if pgrep waybar > /dev/null; then
        echo "Restarting waybar..."
        pkill waybar
        waybar & disown
      else
        echo "Waybar not running, skipping restart"
      fi

      echo "POST-COMMAND FINISHED at $(date)"
      echo "---"
    '';
  };

in
{
  home.packages = with pkgs; [
    waypaper
    generate-colors
  ];
}
