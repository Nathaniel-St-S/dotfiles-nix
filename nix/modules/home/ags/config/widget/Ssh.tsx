import { createPoll } from "ags/time"
import { execAsync, exec } from "ags/process"
import { createComputed } from "ags"
import Gtk from "gi://Gtk"

type SshInfo = {
  connected: boolean
  user: string
  host: string
  ip: string
}

export default function Ssh() {
  // Re-uses your existing waybar-ssh-check and waybar-ssh-info scripts directly
  const info = createPoll<SshInfo>(
    { connected: false, user: "", host: "", ip: "" },
    5000,
    () => {
      try {
        // waybar-ssh-check exits 1 when no connection, prints JSON when connected
        exec(["waybar-ssh-check"])
        return {
          connected: true,
          user: exec(["waybar-ssh-info", "user"]).trim(),
          host: exec(["waybar-ssh-info", "host"]).trim(),
          ip:   exec(["waybar-ssh-info", "ip"]).trim(),
        }
      } catch {
        return { connected: false, user: "", host: "", ip: "" }
      }
    }
  )

  const connected = createComputed(() => info().connected)

  function openSshs() {
    execAsync(["ghostty", "--class=popup.term", "-e", "sshs", "--vim"]).catch(console.error)
  }

  return (
    <box class="ssh" visible={connected}>

      {/* Always-visible icon when any SSH session is active */}
      <button class="ssh-icon" onClicked={openSshs}>
        <label label="" />
      </button>

      {/* Slides in the user / host / ip detail */}
      <Gtk.Revealer
        revealChild={connected}
        transitionType={Gtk.RevealerTransitionType.SLIDE_LEFT}
        transitionDuration={300}
      >
        <box>
          <button class="ssh-item" onClicked={openSshs}>
            <label label={info(i => `  ${i.user} / `)} />
          </button>
          <button class="ssh-item" onClicked={openSshs}>
            <label label={info(i => `  ${i.host} / `)} />
          </button>
          <button class="ssh-item" onClicked={openSshs}>
            <label label={info(i => ` ${i.ip}`)} />
          </button>
        </box>
      </Gtk.Revealer>

    </box>
  )
}
