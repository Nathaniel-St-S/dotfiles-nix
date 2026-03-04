{ pkgs, ... }:

let
  waybar-uptime = pkgs.writeShellScriptBin "waybar-uptime" /* bash */ ''
    UPTIME_PRETTY=$(uptime -p)

    UPTIME_FORMATTED=$(echo "$UPTIME_PRETTY"| sed 's/^up //;s/,*$//;s/minute/m/; s/hour/h/; s/day/d/; s/s//g')

    echo " $UPTIME_FORMATTED"

  '';
in
{
  home.packages = [
    waybar-uptime
  ];
}
