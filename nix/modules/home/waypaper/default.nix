{ pkgs, ... }:

let
  generate-colors = pkgs.writeShellScriptBin "generate-colors" ''
    log=/tmp/waypaper-post.log
    echo "POST-COMMAND CALLED at $(date)"         >> "$log"
    echo "Argument received: '$1'"                >> "$log"

    # Waypaper doesn't reliably pass the wallpaper as $1 — read from config.
    WALLPAPER=$(grep "^wallpaper = " "''${XDG_CONFIG_HOME:-$HOME/.config}/waypaper/config.ini" | cut -d' ' -f3)
    WALLPAPER="''${WALLPAPER/#\~/$HOME}"
    echo "Using wallpaper from config: $WALLPAPER" >> "$log"

    if [ ! -f "$WALLPAPER" ]; then
        echo "ERROR: Wallpaper file not found: $WALLPAPER" >> "$log"
        exit 1
    fi

    # ── Pywal ────────────────────────────────────────────────────────────────
    echo "Running pywal..." >> "$log"
    wal -i "$WALLPAPER" -n -q
    ln -sf "$(cat "''${XDG_CACHE_HOME:-$HOME/.cache}/wal/wal")" "''${XDG_CACHE_HOME:-$HOME/.cache}/current-wallpaper"

    echo "Generating waybar colors..."  >> "$log"
    waybar-generate-colors

    echo "Generating rofi colors..."    >> "$log"
    rofi-generate-colors

    echo "Reloading niri colors..."     >> "$log"
    niri-generate-colors

    echo "Updating btop colors..."      >> "$log"
    btop-generate-colors

    echo "Reloading swaync..."          >> "$log"
    swaync-generate-colors
    swaync-client --reload-config
    swaync-client --reload-css

    echo "Restarting waybar..."         >> "$log"
    pkill waybar
    waybar & disown

    echo "POST-COMMAND FINISHED at $(date)" >> "$log"
    echo "---"                              >> "$log"
  '';

in
{
  home.packages = with pkgs; [
    waypaper
    generate-colors
  ];
}

