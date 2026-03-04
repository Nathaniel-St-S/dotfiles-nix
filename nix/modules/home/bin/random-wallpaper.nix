{ pkgs, inputs, ... }:

let
  backgroundsPath = "${inputs.backgrounds}";
  random-wallpaper = pkgs.writeShellApplication {
    name = "random-wallpaper" ;
    runtimeInputs = with pkgs; [
      coreutils
      swww
      pywal
    ];
    text = /* bash */ ''
      log=/tmp/random-wallpaper.log
      exec >> "$log" 2>&1
      echo "random-wallpaper called at $(date)"

      WALLPAPER=$(find "${backgroundsPath}" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) | shuf -n1)

      if [ -z "$WALLPAPER" ]; then
        echo "ERROR: no wallpaper found in ${backgroundsPath}"
        exit 1
      fi

      echo "Selected: $WALLPAPER"

      # Update waypaper config so generate-colors picks it up
      CONFIG="''${XDG_CONFIG_HOME:-$HOME/.config}/waypaper/config.ini"
      mkdir -p "$(dirname "$CONFIG")"
      if [ -f "$CONFIG" ]; then
        sed -i "s|^wallpaper = .*|wallpaper = $WALLPAPER|" "$CONFIG"
      else
        printf '[Settings]\nwallpaper = %s\n' "$WALLPAPER" > "$CONFIG"
      fi

      # Set the wallpaper
      swww img "$WALLPAPER" --transition-type fade --transition-duration 1

      # Regenerate the colorscheme and reload everything
      generate-colors

      echo "random-wallpaper finished at $(date)"
      echo "---"
    '';
  };

in
{
  home.packages = [
    random-wallpaper
  ];
}

