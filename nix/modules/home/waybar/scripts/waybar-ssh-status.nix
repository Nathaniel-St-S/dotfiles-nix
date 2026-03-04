{ pkgs, ... }:
let
  waybar-ssh-status = pkgs.writeShellScriptBin "waybar-ssh-status" /* bash */ ''
    ssh_count=$(ss -tn | grep ':22' | grep ESTAB | wc -l)

    if [ "$ssh_count" -gt 0 ]; then
        echo "$ssh_count active"
    else
        echo "ready"
    fi
  '';

in
{
  home.packages = [
    waybar-ssh-status
  ];
}
