{ pkgs, autoImport, ... }:

let
  waybar-generate-colors = pkgs.writeShellScriptBin "waybar-generate-colors" /* bash */ ''
    source "$HOME/.cache/wal/colors.sh"

    mkdir -p "''${XDG_CONFIG_HOME:-$HOME/.config}/waybar"

    cat > "''${XDG_CONFIG_HOME:-$HOME/.config}/waybar/colors-waybar.css" << EOF
    /* Pywal colors for Waybar */
    @define-color backgroundlight ''${color1};
    @define-color backgrounddark ''${color2};
    @define-color backgrounddim ''${color3};
    @define-color workspacesbackground1 ''${color4};
    @define-color workspacesbackground2 ''${color5};
    @define-color workspacesbackground3 ''${color6};
    @define-color on_primary_container ''${foreground};
    @define-color primary_container ''${color0};
    @define-color bordercolor ''${color6};
    @define-color on_surface ''${foreground};
    @define-color textcolor1 ''${color7};
    @define-color textcolor2 ''${color8};
    @define-color textcolor3 ''${color6};
    @define-color iconcolor ''${color6};
    @define-color canvas ''${background};
    EOF
  '';

in
{
  home.packages = with pkgs; [
    waybar-generate-colors
    sshs
    impala
    bluetui
    wiremix
    calcurse
  ];

  imports = autoImport { path = ./scripts; };

  programs.waybar = {
    enable = true;

    # ── Bar layout ────────────────────────────────────────────────────────────
    settings = [{
      layer    = "top";
      position = "top";
      "margin-bottom" = 0;
      "margin-left"   = 0;
      "margin-right"  = 0;
      spacing  = 0;

      "modules-left" = [ "niri/workspaces" "mpris" ];

      "modules-center" = [
        "clock" "pulseaudio" "bluetooth" "battery"
        "network" "group/hardware" "tray" "custom/notification"
      ];

      "modules-right" = [ "group/ssh" ];

      # ── Workspaces ──────────────────────────────────────────────────────────
      "niri/workspaces" = {
        "on-click"   = "activate";
        "active-only"  = false;
        "all-outputs"  = true;
        format         = "{}";
        "format-icons" = {
          urgent  = "";
          active  = "";
          default = "";
        };
        "persistent-workspaces"."*" = 3;
      };

      # ── Notifications ───────────────────────────────────────────────────────
      "custom/notification" = {
        tooltip  = false;
        format   = "{icon}";
        "format-icons" = {
          notification              = "";
          none                      = "";
          "dnd-notification"        = "";
          "dnd-none"                = "";
          "inhibited-notification"  = "";
          "inhibited-none"          = "";
          "dnd-inhibited-notification" = "";
          "dnd-inhibited-none"      = "";
        };
        "return-type"    = "json";
        "exec-if"        = "which swaync-client";
        exec             = "swaync-client -swb";
        "on-click-right" = "swaync-client -d -sw";
        "on-click"       = "swaync-client -t -sw";
        escape           = true;
      };

      # ── Mpris ───────────────────────────────────────────────────────────────
      mpris = {
        format         = "{player_icon} {artist} - {title}";
        "format-paused" = "<span color='grey'>{status_icon} {artist} - {title}</span>";
        "max-length"   = 50;
        "player-icons" = {
          default = "⏸";
          mpv     = "🎵";
        };
        "status-icons".paused = "▶";
      };

      # ── Tray ────────────────────────────────────────────────────────────────
      tray = {
        "icon-size" = 21;
        spacing     = 10;
      };

      # ── Clock ───────────────────────────────────────────────────────────────
      clock = {
        format           = "{:%I:%M %p}   ";
        "format-alt"     = "{:%H:%M:%S  -  %Z (%z)}";
        tooltip          = false;
        "on-click-right" = "ghostty --class=popup.term -e calcurse";
      };

      # ── Hardware group ───────────────────────────────────────────────────────
      "custom/system" = { format = ""; tooltip = false; };

      cpu = {
        format   = "/  {usage}% ";
        "on-click" = "ghostty --class=popup.term -e btop";
      };

      memory = {
        format   = "/  {}% ";
        "on-click" = "ghostty --class=popup.term -e btop";
      };

      disk = {
        interval   = 30;
        format     = " {percentage_used}% ";
        path       = "/";
        "on-click" = "ghostty --class=popup.term -e btop";
      };

      "group/hardware" = {
        orientation = "inherit";
        drawer = {
          "transition-duration"      = 300;
          "children-class"           = "not-memory";
          "transition-left-to-right" = false;
        };
        modules = [ "custom/system" "disk" "cpu" "memory" ];
      };

      # ── SSH group ────────────────────────────────────────────────────────────
      "custom/server" = {
        format       = "";
        tooltip      = false;
        interval     = 5;
        exec         = "waybar-ssh-check";
        "return-type" = "json";
      };

      "custom/ssh-user" = {
        format     = " {} / ";
        tooltip    = false;
        interval   = 5;
        exec       = "waybar-ssh-info user";
        "on-click" = "ghostty --class=popup.term -e sshs --vim";
      };

      "custom/ssh-host" = {
        format     = " {} / ";
        tooltip    = false;
        interval   = 5;
        exec       = "waybar-ssh-info host";
        "on-click" = "ghostty --class=popup.term -e sshs --vim";
      };

      "custom/ssh-ip" = {
        format     = " {}";
        tooltip    = false;
        interval   = 5;
        exec       = "waybar-ssh-info ip";
        "on-click" = "ghostty --class=popup.term -e sshs --vim";
      };

      "custom/uptime" = {
        format   = "{}";
        tooltip  = false;
        interval = 1600;
        exec     = "waybar-uptime";
      };

      "group/ssh" = {
        orientation = "inherit";
        drawer = {
          "transition-duration"      = 300;
          "children-class"           = "not-memory";
          "transition-left-to-right" = false;
        };
        modules = [
          "custom/server"
          "custom/ssh-user"
          "custom/ssh-host"
          "custom/ssh-ip"
        ];
      };

      # ── Network ──────────────────────────────────────────────────────────────
      network = {
        format                   = "{ifname}";
        "format-wifi"            = " ";
        "format-ethernet"        = "";
        "format-disconnected"    = "Not Connected";
        "tooltip-format"         = " {ifname} via {gwaddri}";
        "tooltip-format-wifi"    = "   {essid} ({signalStrength}%)";
        "tooltip-format-ethernet" = "  {ifname} ({ipaddr}/{cidr})";
        "tooltip-format-disconnected" = "Disconnected";
        "max-length"             = 50;
        "on-click"               = "ghostty --class=popup.term -e impala || nm-connection-editor || nmtui";
      };

      # ── Battery ──────────────────────────────────────────────────────────────
      battery = {
        states = {
          warning  = 30;
          critical = 15;
        };
        format           = "{icon} {capacity}%";
        "format-charging" = " {capacity}%";
        "format-plugged"  = " {capacity}%";
        "format-alt"     = "{icon} {time}";
        "format-icons"   = [" " " " " " " " " "];
      };

      # ── Pulseaudio ───────────────────────────────────────────────────────────
      pulseaudio = {
        "naturaul-scroll"       = "true";
        format                  = "{icon} {volume}%";
        "format-bluetooth"      = "{volume}%  {icon} {format_source}";
        "format-bluetooth-muted" = "  {icon} {format_source}";
        "format-muted"          = "  {format_source}";
        "format-source"         = "{volume}% ";
        "format-source-muted"   = "";
        "format-icons" = {
          headphone   = " ";
          "hands-free" = " ";
          headset     = " ";
          phone       = " ";
          portable    = " ";
          car         = " ";
          default     = ["" " " " "];
        };
        "on-click" = "ghostty --class=popup.term -e wiremix || pavucontrol || pwvucontrol";
      };

      # ── Bluetooth ────────────────────────────────────────────────────────────
      bluetooth = {
        "format-disabled"      = "";
        "format-off"           = "";
        interval               = 30;
        "on-click"             = "ghostty --class=popup.term -e bluetui";
        "format-no-controller" = "";
      };
    }];

    style = import ./style.nix;
  };
}
