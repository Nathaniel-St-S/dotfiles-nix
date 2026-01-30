{ pkgs, ... }:

let
  rofi-generate-colors = pkgs.writeShellScriptBin "rofi-generate-colors" ''
    log=/tmp/rofi-colors.log
    echo "Generating rofi colors at $(date)" >> "$log"

    if [ ! -f "$HOME/.cache/wal/colors.sh" ]; then
      echo "ERROR: ~/.cache/wal/colors.sh not found!" >> "$log"
      exit 1
    fi

    source "$HOME/.cache/wal/colors.sh"
    echo "Pywal colors loaded: bg=$background, fg=$foreground" >> "$log"

    mkdir -p "$HOME/.config/rofi"

    cat > "$HOME/.config/rofi/colors.rasi" << EOF
    /**
     * Rofi colors from pywal
     * Generated at $(date)
     **/

    * {
        background:     ''${background}FF;
        background-alt: ''${color1}FF;
        foreground:     ''${foreground}FF;
        selected:       ''${color4}FF;
        active:         ''${color2}FF;
        urgent:         ''${color1}FF;
    }
    EOF

    echo "Rofi colors generated successfully" >> "$log"
  '';
in
{
  home.packages = [ rofi-generate-colors ];
}
