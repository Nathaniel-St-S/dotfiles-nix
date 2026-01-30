{ pkgs, ... }:

let
  swaync-generate-colors = pkgs.writeShellScriptBin "swaync-generate-colors" ''
    log=/tmp/swaync-colors.log
    echo "Generating swaync colors at $(date)" >> "$log"

    if [ ! -f "$HOME/.cache/wal/colors.sh" ]; then
      echo "ERROR: ~/.cache/wal/colors.sh not found!" >> "$log"
      exit 1
    fi

    source "$HOME/.cache/wal/colors.sh"
    echo "Pywal colors loaded: bg=$background, fg=$foreground" >> "$log"

    cat > "$HOME/.config/swaync/colors.css" << EOF
    /* Pywal colors for swaync */
    /* Generated at $(date) */

    @define-color cc-bg ''${background};
    @define-color noti-bg ''${color0};
    @define-color noti-bg-darker ''${background};
    @define-color noti-bg-hover ''${color8};
    @define-color noti-bg-focus ''${color8};
    @define-color noti-close-bg ''${color8};
    @define-color noti-close-bg-hover ''${color1};
    @define-color text-color ''${foreground};
    @define-color text-color-disabled ''${color8};
    @define-color bg-selected ''${color1};

    @define-color black ''${color0};
    @define-color red ''${color1};
    @define-color green ''${color2};
    @define-color yellow ''${color3};
    @define-color blue ''${color4};
    @define-color purple ''${color5};
    @define-color aqua ''${color6};
    @define-color gray ''${color7};
    @define-color brgray ''${color8};
    @define-color brred ''${color1};
    @define-color brgreen ''${color2};
    @define-color bryellow ''${color3};
    @define-color brblue ''${color4};
    @define-color brpurple ''${color5};
    @define-color braqua ''${color6};
    @define-color white ''${foreground};
    @define-color bg2 ''${color8};
    EOF

    echo "swaync colors generated successfully" >> "$log"
  '';
in
{
  home.packages = [ swaync-generate-colors ];
}
