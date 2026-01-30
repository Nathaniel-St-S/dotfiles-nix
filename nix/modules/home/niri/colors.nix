{ pkgs, ... }:

let
  niri-generate-colors = pkgs.writeShellScriptBin "niri-generate-colors" ''
    set -euo pipefail
    log=/tmp/niri-colors.log
    echo "Generating niri colors at $(date)" >> "$log"

    if [ ! -f "$HOME/.cache/wal/colors.sh" ]; then
      echo "ERROR: ~/.cache/wal/colors.sh not found!" >> "$log"
      exit 1
    fi

    set +u
    source "$HOME/.cache/wal/colors.sh"
    set -u
    echo "Pywal colors loaded: bg=$background, fg=$foreground" >> "$log"

    cat > "$HOME/.config/niri/colors.kdl" << EOF
// Auto-generated from pywal — $(date)
layout {
  focus-ring {
    active-gradient from="''${color5}" to="''${color4}" angle=45
  }
  border {
    active-gradient from="''${color5}" to="''${color4}" angle=45
  }
}
recent-windows {
  highlight {
    active-color "''${color4}"
    urgent-color "''${color5}"
  }
}
EOF

    niri msg action reload-config 2>/dev/null || true
    echo "Niri colors written and config reloaded" >> "$log"
  '';
in
{
  home.packages = [ niri-generate-colors ];
}
