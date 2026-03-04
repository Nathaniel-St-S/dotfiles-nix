# css
''
  @import 'colors-waybar.css';
  /* -----------------------------------------------------
   * General
   * ----------------------------------------------------- */
  
  * {
      font-family: "Fira Sans Semibold", "Fira Code", "Font Awesome 7 Free", "Font Awesome 7 Brands", "Font Awesome 6 Free", "Font Awesome 6 Brands", FontAwesome, Roboto, Helvetica, Arial, sans-serif;
      min-height: 10px;
      border: none;
  }
  
  /* -----------------------------------------------------
   * Window
   * ----------------------------------------------------- */
  
  window#waybar {
      background: @canvas;
      transition-property: background-color;
      transition-duration: .5s;
  }
  
  window#waybar.float #window {
      background-color: transparent;
  }
  
  /* -----------------------------------------------------
   * Workspaces
   * ----------------------------------------------------- */
  
  #workspaces {
      padding: 0px 2px 0px 2px;
      border-radius: 30px;
      font-weight: bold;
      font-style: normal;
      color: transparent;
  }
  
  #workspaces button {
      padding: 0px 6px;
      margin: 3px 2px;
      min-width: 2px;
      min-height: 2px;
      border-radius: 10px;
      border: none;
      outline: none;
      background: @workspacesbackground2;
      background-clip: padding-box;
      color: transparent;
      transition: all 0.5s ease-in-out;
      box-shadow: none;
  }
  
  #workspaces button.active {
      background: @workspacesbackground3;
      color: transparent;
      border-radius: 18px;
      min-width: 45px;
      transition: all 0.5s ease-in-out;
  }
  
  #workspaces button:hover {
      background: @workspacesbackground3;
      color: transparent;
      border-radius: 10px;
      text-shadow: none;
  }
  
  /* -----------------------------------------------------
   * Uptime
   * ----------------------------------------------------- */
   
  #custom-uptime {
      background-color: @backgrounddark;
      font-size: 12px;
      color: @textcolor1;
      border-radius: 15px;
      padding: 2px 10px 0px 10px;
  }
  
  /* -----------------------------------------------------
   * Tooltips
   * ----------------------------------------------------- */
  
  tooltip {
      border-radius: 16px;
      background-color: @backgrounddark;
      opacity: 1;
      padding: 20px;
      margin: 0px;
  }
  
  tooltip label {
      color: @textcolor2;
  }
  
  /* -----------------------------------------------------
   * Taskbar
   * ----------------------------------------------------- */
  
  #taskbar {
      background: @backgroundlight;
      margin: 5px 15px 5px 0px;
      padding:0px;
      border-radius: 15px;
      font-weight: normal;
      font-style: normal;
      border: 3px solid @backgroundlight;
  }
  
  #taskbar button {
      margin:0;
      border-radius: 15px;
      padding: 0px 5px 0px 5px;
  }
  
  /* -----------------------------------------------------
   * Modules
   * ----------------------------------------------------- */
  
  .modules-left > widget:first-child > #workspaces {
      margin-left: 0;
  }
  
  .modules-right > widget:last-child > #workspaces {
      margin-right: 0;
  }
  
  /* -----------------------------------------------------
   * Hardware Group
   * ----------------------------------------------------- */
  
  #custom-system {
    margin-right: 23px;
    font-size: 12px;
    font-weight: bold;
    color: @iconcolor;
  }
  
   #disk,#memory,#cpu,#language {
      margin:0px;
      padding:0px;
      font-size:12px;
      color: @iconcolor;
  }
  
  #language {
      margin-right:10px;
  }
  
  /* -----------------------------------------------------
   * SSH Group
   * ----------------------------------------------------- */
  #custom-ssh-user,
  #custom-ssh-host,
  #custom-ssh-ip,
  #custom-server {
    margin: 0px;
    padding: 0px;
    font-size: 12px;
    color: @iconcolor;
  }
  
  #custom-server.disconnected {
    min-width: 0;
    min-height: 0;
    padding: 0;
    margin: 0;
    border: none;
    font-size: 0;
  }
  
  #custom-ssh-ip {
    margin-right: 10px;
  }
  
  /* -----------------------------------------------------
   * Clock
   * ----------------------------------------------------- */
  
  #clock {
      background: transparent;
      font-size: 12px;
      color: @textcolor3;
      border-radius: 15px;
      padding: 2px 10px 0px 10px;
  }
  
  #clock:hover {
    color: @textcolor2;
    background-color: @backgrounddark;
  }
  
  /* -----------------------------------------------------
   * Backlight
   * ----------------------------------------------------- */
  
   #backlight {
      background-color: @backgroundlight;
      font-size: 12px;
      color: @textcolor2;
      border-radius: 15px;
      padding: 2px 10px 0px 10px;
      margin: 5px 15px 5px 0px;
  }
  
  /* -----------------------------------------------------
   * Pulseaudio
   * ----------------------------------------------------- */
  
  #pulseaudio {
      background-color: transparent;
      font-size: 12px;
      color: @textcolor3;
      border-radius: 15px;
      padding: 2px 10px 0px 10px;
  }
  
  #pulseaudio.muted {
      background-color: @backgrounddark;
      color: @textcolor1;
  }
  
  /* -----------------------------------------------------
   * Network
   * ----------------------------------------------------- */
  
  #network {
      background-color: transparent;
      font-size: 12px;
      color: @textcolor3;
      border-radius: 15px;
      padding: 2px 10px 2px 15px;
  }
  
  #network.ethernet {
      background-color: transparent;
      color: @textcolor3;
  }
  
  #network.wifi {
      background-color: transparent;
      color: @textcolor3;
  }
  
  /* -----------------------------------------------------
   * Bluetooth
   * ----------------------------------------------------- */
  
   #bluetooth, #bluetooth.on, #bluetooth.connected {
      background-color: transparent;
      font-size: 12px;
      color: @textcolor3;
      border-radius: 15px;
      padding: 2px 10px 0px 10px;
  }
  
  #bluetooth.off {
      background-color: transparent;
      padding: 0px;
      margin: 0px;
  }
  
  /* -----------------------------------------------------
   * Battery
   * ----------------------------------------------------- */
  
  #battery {
      background-color: transparent;
      font-size: 12px;
      color: @textcolor3;
      border-radius: 15px;
      padding: 2px 15px 0px 10px;
  }
  
  #battery.charging, #battery.plugged {
      color: @textcolor2;
      background-color: @backgrounddark;
  }
  
  @keyframes blink {
      to {
          background-color: @backgroundlight;
          color: @textcolor2;
      }
  }
  
  #battery.critical:not(.charging) {
      background-color: #f53c3c;
      color: @textcolor3;
      animation-name: blink;
      animation-duration: 0.5s;
      animation-timing-function: linear;
      animation-iteration-count: infinite;
      animation-direction: alternate;
  }
  
  /* -----------------------------------------------------
   * Tray
   * ----------------------------------------------------- */
  
  #tray {
      margin:0px 10px 0px 0px;
  }
  
  #tray > .passive {
      -gtk-icon-effect: dim;
  }
  
  #tray > .needs-attention {
      -gtk-icon-effect: highlight;
      background-color: #eb4d4b;
  }
  
  /* -----------------------------------------------------
   * Notifications
   * ----------------------------------------------------- */
  
  #custom-notification {
      font-family: "JetBrains Mono Nerd Font";
      font-size: 12px;
      color: @textcolor3;
  }
  
  /* -----------------------------------------------------
   * Other
   * ----------------------------------------------------- */
   
  label:focus {
      background-color: #000000;
  }
  
  #backlight {
      background-color: #90b1b1;
  }
  
  #network {
      background-color: #2980b9;
  }
  
  #network.disconnected {
      background-color: #f53c3c;
  }
  
  #custom-lock {
    color: @textcolor1;
  }
''
