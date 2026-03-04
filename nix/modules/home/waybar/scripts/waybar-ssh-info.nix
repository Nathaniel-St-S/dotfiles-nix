{ pkgs, ... }:

let
  waybar-ssh-info = pkgs.writeShellScriptBin "waybar-ssh-info" /* bash */ ''
    # Find the SSH client process (not sshd server)
    ssh_process=$(ps aux | grep "[s]sh " | grep -v "sshd" | grep -v "ssh-agent" | tail -n 1)

    if [ -z "$ssh_process" ]; then
        echo ""
        exit 0
    fi

    # Extract the SSH command
    ssh_cmd=$(echo "$ssh_process" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i}')

    case "$1" in
        user)
            # Extract user from user@host format
            if [[ "$ssh_cmd" =~ ([a-zA-Z0-9_-]+)@ ]]; then
                echo "''${BASH_REMATCH[1]}"
            else
                echo "$(whoami)"
            fi
            ;;
        host)
            # Extract hostname from command
            if [[ "$ssh_cmd" =~ @([a-zA-Z0-9._-]+) ]]; then
                echo "''${BASH_REMATCH[1]}"
            elif [[ "$ssh_cmd" =~ ssh[[:space:]]+([a-zA-Z0-9._-]+) ]]; then
                echo "''${BASH_REMATCH[1]}"
            else
                echo "unknown"
            fi
            ;;
        ip)
            # Get IP from active connection
            remote=$(ss -tnp 2>/dev/null | grep 'ssh' | grep ESTAB | grep -v '127.0.0.1' | grep -v '::1' | head -n 1 | awk '{print $5}' | cut -d: -f1)
            echo "$remote"
            ;;
    esac
  '';
in
{
  home.packages = [
    waybar-ssh-info
  ];
}
