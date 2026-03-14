{ pkgs, ... }:

let
  workspace-script = pkgs.writeShellScript "workspace" ''
    workspaces() {
      WORKSPACES=$(niri msg --json workspaces | jq 'sort_by(.idx)')
      WINDOWS=$(niri msg --json windows)

      RESULT="(box :class \"works\" :orientation \"v\" :halign \"center\" :valign \"start\" :space-evenly \"false\" :spacing \"-5\""

      while IFS= read -r ws; do
        id=$(echo "$ws" | jq -r '.id')
        idx=$(echo "$ws" | jq -r '.idx')
        focused=$(echo "$ws" | jq -r '.is_focused')
        has_windows=$(echo "$WINDOWS" | jq -r --argjson id "$id" \
          'map(select(.workspace_id == $id)) | length > 0')

        if [ "$focused" = "true" ]; then
          class="focused"
        elif [ "$has_windows" = "true" ]; then
          class="occupied"
        else
          class="empty"
        fi

        RESULT="$RESULT (button :onclick \"niri msg action focus-workspace $idx\" :class \"$class\" \"\")"
      done < <(echo "$WORKSPACES" | jq -c '.[]')

      RESULT="$RESULT)"
      echo "$RESULT"
    }
    workspaces
    niri msg event-stream | grep --line-buffered \
      -E "WorkspacesChanged|WorkspaceActivated|WindowOpenedOrChanged|WindowClosed|WindowFocusChanged" \
      | while read -r _; do
      workspaces
    done
  '';

  calendar-script = pkgs.writeShellScript "calendar" ''
    month=$(date +%m)
    month=$((month-1)) # for some reason eww gives the month as a zero-based integer

    echo $month
  '';

  battery-script = pkgs.writeShellScript "battery" ''
    bat=/sys/class/power_supply/BAT0/
    per="$(cat "$bat/capacity")"

    icon() {

      [ $(cat "$bat/status") = Charging ] && echo "" && exit

      if [ "$per" -gt "90" ]; then
        icon=""
      elif [ "$per" -gt "80" ]; then
        icon=""
      elif [ "$per" -gt "70" ]; then
        icon=""
      elif [ "$per" -gt "60" ]; then
        icon=""
      elif [ "$per" -gt "50" ]; then
        icon=""
      elif [ "$per" -gt "40" ]; then
        icon=""
      elif [ "$per" -gt "30" ]; then
        icon=""
      elif [ "$per" -gt "20" ]; then
        icon=""
      elif [ "$per" -gt "10" ]; then
        icon=""
        notify-send -u critical "Battery Low" "Connect Charger"
      elif [ "$per" -gt "0" ]; then
        icon=""
        notify-send -u critical "Battery Low" "Connect Charger"
      else
        echo  && exit
      fi
      echo "$icon"
    }

    percent() {
      echo $per
    }

    [ "$1" = "icon" ] && icon && exit
    [ "$1" = "percent" ] && percent && exit
    exit
  '';

  popup-script = pkgs.writeShellScript "popup" ''
    calendar(){
      LOCK_FILE="$HOME/.cache/eww-calendar.lock"
      EWW_BIN="$HOME/.local/bin/eww"

      run() {
        ''${EWW_BIN} -c $HOME/.config/eww/bar open calendar
      }

      # Run eww daemon if not running
      if [[ ! `pidof eww` ]]; then
        ''${EWW_BIN} daemon
        sleep 1
      fi

      # Open widgets
      if [[ ! -f "$LOCK_FILE" ]]; then
        touch "$LOCK_FILE"
        run
      else
        ''${EWW_BIN} -c $HOME/.config/eww/bar close calendar
        rm "$LOCK_FILE"
      fi
    }

    if [ "$1" = "launcher" ]; then
      $HOME/.local/bin/launcher
    elif [ "$1" = "wifi" ]; then
      ghostty -e nmtui
    elif [ "$1" = "audio" ]; then
      pavucontrol
    elif [ "$1" = "calendar" ]; then
      calendar
    fi
  '';
  
  wifi-script = pkgs.writeShellScript "wifi" ''
    symbol() {
      [ $(cat /sys/class/net/w*/operstate) = down ] && echo  && exit
      echo 
    }

    name() {
      nmcli | grep "^wlp" | sed 's/\ connected\ to\ /Connected to /g' | cut -d ':' -f2
    }

    [ "$1" = "icon" ] && symbol && exit
    [ "$1" = "name" ] && name && exit
  '';
in
{
  home.packages = with pkgs; [ eww jq ];

  xdg.configFile = {
    "eww/eww.yuck".source = ./eww.yuck;
    "eww/eww.scss".source = ./eww.scss;
    "eww/scripts/workspace" = {
      source     = workspace-script;
      executable = true;
    };
    "eww/scripts/calendar" = {
      source     = calendar-script;
      executable = true;
    };
    "eww/scripts/battery" = {
      source     = battery-script;
      executable = true;
    };
    "eww/scripts/popup" = {
      source     = popup-script;
      executable = true;
    };
    "eww/scripts/wifi" = {
      source     = wifi-script;
      executable = true;
    };
  };
}
