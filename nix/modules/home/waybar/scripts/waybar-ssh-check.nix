{ pkgs, ... }:

let
  waybar-ssh-check = pkgs.writeShellScriptBin "waybar-ssh-check" /* bash */ ''
    ssh_count=$(ss -tnp 2>/dev/null | grep 'ssh' | grep ESTAB | grep -v '127.0.0.1' | grep -v '::1' | wc -l)

    if [ "$ssh_count" -gt 0 ]; then
        echo '{"text":"", "class":"connected", "tooltip":""}'
    else
        # Return nothing to hide completely
        exit 1
    fi
  '';
in
{
  home.packages = [
    waybar-ssh-check
  ];
}
