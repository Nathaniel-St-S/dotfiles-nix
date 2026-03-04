{ pkgs, ... }:

let 
  sysinfo = pkgs.writeShellScriptBin "sysinfo" /* bash */ ''
    # Colors
    BOLD='\033[1m'
    CYAN='\033[0;36m'
    RESET='\033[0m'
    
    # Header
    echo -e "''${BOLD}''${CYAN}System Information''${RESET}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Hostname
    if [ -f /etc/hostname ]; then
        hostname_val=$(cat /etc/hostname)
    else
        hostname_val=$(uname -n)
    fi
    echo -e "''${CYAN}Hostname:''${RESET} $hostname_val"
    
    # User
    user=$(whoami)
    echo -e "''${CYAN}User:''${RESET} $user"
    
    # Kernel
    echo -e "''${CYAN}Kernel:''${RESET} $(uname -r)"
    
    # OS/Distro
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo -e "''${CYAN}OS:''${RESET} $PRETTY_NAME"
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        echo -e "''${CYAN}OS:''${RESET} $DISTRIB_DESCRIPTION"
    else
        echo -e "''${CYAN}OS:''${RESET} $(uname -s)"
    fi
    
    # CPU
    cpu=$(grep -m1 "model name" /proc/cpuinfo | cut -d':' -f2 | xargs)
    echo -e "''${CYAN}CPU:''${RESET} $cpu"
    
    # GPU
    if command -v lspci &> /dev/null; then
        gpu=$(lspci | grep -i 'vga\|3d\|display' | cut -d':' -f3 | xargs | head -n1)
        [ -n "$gpu" ] && echo -e "''${CYAN}GPU:''${RESET} $gpu"
    fi
    
    # Memory
    mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    mem_available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    mem_used=$((mem_total - mem_available))
    mem_total_gb=$(awk "BEGIN {printf \"%.1f\", $mem_total/1024/1024}")
    mem_used_gb=$(awk "BEGIN {printf \"%.1f\", $mem_used/1024/1024}")
    mem_percent=$(awk "BEGIN {printf \"%.0f\", ($mem_used/$mem_total)*100}")
    echo -e "''${CYAN}Memory:''${RESET} ''${mem_used_gb}GB / ''${mem_total_gb}GB (''${mem_percent}%)"
    
    # Swap
    swap_total=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
    swap_free=$(grep SwapFree /proc/meminfo | awk '{print $2}')
    swap_used=$((swap_total - swap_free))
    swap_total_gb=$(awk "BEGIN {printf \"%.1f\", $swap_total/1024/1024}")
    swap_used_gb=$(awk "BEGIN {printf \"%.1f\", $swap_used/1024/1024}")
    if [ "$swap_total" -gt 0 ]; then
        swap_percent=$(awk "BEGIN {printf \"%.0f\", ($swap_used/$swap_total)*100}")
        echo -e "''${CYAN}Swap:''${RESET} ''${swap_used_gb}GB / ''${swap_total_gb}GB (''${swap_percent}%)"
    else
        echo -e "''${CYAN}Swap:''${RESET} ''${swap_used_gb}GB / ''${swap_total_gb}GB"
    fi
    
    # Disk Usage
    disk_info=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')
    echo -e "''${CYAN}Disk:''${RESET} $disk_info"
    
    # Desktop Environment
    de=""
    de_list=("GNOME" "KDE" "XFCE" "LXQt" "LXDE" "Cinnamon" "MATE" "Pantheon" "Budgie" "Enlightenment" "COSMIC")
    
    if [ -n "$XDG_CURRENT_DESKTOP" ]; then
        de="$XDG_CURRENT_DESKTOP"
    elif [ -n "$DESKTOP_SESSION" ]; then
        de="$DESKTOP_SESSION"
    elif [ -n "$XDG_SESSION_DESKTOP" ]; then
        de="$XDG_SESSION_DESKTOP"
    fi
    
    # Check if it's actually a DE or just a WM
    is_de=false
    if [ -n "$de" ]; then
        for desktop in "''${de_list[@]}"; do
            if echo "$de" | grep -qi "$desktop"; then
                is_de=true
                break
            fi
        done
    fi
    
    # Detect Window Manager
    wm=""
    if [ -n "$WAYLAND_DISPLAY" ]; then
        # Wayland compositors
        if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
            wm="Hyprland"
        elif [ -n "$SWAYSOCK" ]; then
            wm="Sway"
        elif pgrep -x "river" > /dev/null; then
            wm="River"
        elif pgrep -x "wayfire" > /dev/null; then
            wm="Wayfire"
        elif pgrep -x "niri" > /dev/null; then
            wm="Niri"
        fi
    elif [ -n "$DISPLAY" ]; then
        # X11 window managers
        if pgrep -x "i3" > /dev/null; then
            wm="i3"
        elif pgrep -x "bspwm" > /dev/null; then
            wm="bspwm"
        elif pgrep -x "awesome" > /dev/null; then
            wm="awesome"
        elif pgrep -x "dwm" > /dev/null; then
            wm="dwm"
        elif pgrep -x "xmonad" > /dev/null; then
            wm="xmonad"
        elif command -v xprop &> /dev/null && xprop -root -notype _NET_SUPPORTING_WM_CHECK 2>/dev/null | grep -q "window id"; then
            wm=$(xprop -id $(xprop -root -notype _NET_SUPPORTING_WM_CHECK | cut -d'#' -f2) -notype -len 100 -f _NET_WM_NAME 8t 2>/dev/null | grep "_NET_WM_NAME" | cut -d'"' -f2)
        fi
    fi
    
    # Display DE and WM
    if [ "$is_de" = true ]; then
        echo -e "''${CYAN}DE:''${RESET} $de"
    fi
    
    if [ -n "$wm" ]; then
        echo -e "''${CYAN}WM:''${RESET} $wm"
    fi
    
    # If neither DE nor WM, show NONE
    if [ "$is_de" = false ] && [ -z "$wm" ]; then
        echo -e "''${CYAN}DE:''${RESET} NONE"
    fi
    
    # Shell
    shell_name=$(basename "$SHELL")
    echo -e "''${CYAN}Shell:''${RESET} $shell_name"
    
    # Terminal
    if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        echo -e "''${CYAN}Terminal:''${RESET} sshd"
    elif [ -n "$KITTY_WINDOW_ID" ]; then
        echo -e "''${CYAN}Terminal:''${RESET} kitty"
    elif [ -n "$ALACRITTY_SOCKET" ]; then
        echo -e "''${CYAN}Terminal:''${RESET} alacritty"
    elif [ -n "$TERM_PROGRAM" ]; then
        echo -e "''${CYAN}Terminal:''${RESET} $TERM_PROGRAM"
    elif [ -n "$KONSOLE_VERSION" ]; then
        echo -e "''${CYAN}Terminal:''${RESET} konsole"
    elif [ -n "$GNOME_TERMINAL_SERVICE" ]; then
        echo -e "''${CYAN}Terminal:''${RESET} gnome-terminal"
    elif [ -n "$TMUX" ]; then
        echo -e "''${CYAN}Terminal:''${RESET} tmux"
    else
        # Fallback: try to detect from parent process
        term=$(ps -o comm= -p $PPID 2>/dev/null)
        if [ -n "$term" ]; then
            echo -e "''${CYAN}Terminal:''${RESET} $term"
        fi
    fi
    
    # Packages
    pkg_count=""
    if command -v nix-store &> /dev/null; then
        nix_count=$(nix-store -q --requisites /run/current-system 2>/dev/null | wc -l)
        [ $nix_count -gt 0 ] && pkg_count="$nix_count (nix)"
    fi
    if command -v dpkg &> /dev/null; then
        dpkg_count=$(dpkg -l | grep -c '^ii')
        pkg_count="''${pkg_count:+$pkg_count, }$dpkg_count (dpkg)"
    fi
    if command -v rpm &> /dev/null; then
        rpm_count=$(rpm -qa | wc -l)
        pkg_count="''${pkg_count:+$pkg_count, }$rpm_count (rpm)"
    fi
    if command -v pacman &> /dev/null; then
        pacman_count=$(pacman -Q | wc -l)
        pkg_count="''${pkg_count:+$pkg_count, }$pacman_count (pacman)"
    fi
    if command -v flatpak &> /dev/null; then
        flatpak_count=$(flatpak list 2>/dev/null | wc -l)
        [ $flatpak_count -gt 0 ] && pkg_count="''${pkg_count:+$pkg_count, }$flatpak_count (flatpak)"
    fi
    if command -v snap &> /dev/null; then
        snap_count=$(snap list 2>/dev/null | tail -n +2 | wc -l)
        [ $snap_count -gt 0 ] && pkg_count="''${pkg_count:+$pkg_count, }$snap_count (snap)"
    fi
    [ -n "$pkg_count" ] && echo -e "''${CYAN}Packages:''${RESET} $pkg_count"
    
    # IP Address
    if command -v ip &> /dev/null; then
        ip_addr=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n1)
    elif [ -f /proc/net/fib_trie ]; then
        ip_addr=$(grep -A1 "host LOCAL" /proc/net/fib_trie | grep -oP '\d+\.\d+\.\d+\.\d+' | grep -v '127.0.0.1' | head -n1)
    fi
    [ -n "$ip_addr" ] && echo -e "''${CYAN}IP Address:''${RESET} $ip_addr"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  '';

in
{
  home.packages = [
    sysinfo
  ];
}
