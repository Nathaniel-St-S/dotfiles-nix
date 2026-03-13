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
  print("Ssh: init")
  const info = createPoll<SshInfo>(
    { connected: false, user: "", host: "", ip: "" },
    5000,
    () => {
      try {
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
  print("Ssh: poll created")
  const connected = createComputed(() => info().connected)
  print("Ssh: returning JSX")

  return (
    <box class="ssh" visible={connected}>
      <button class="ssh-icon" onClicked={() =>
        execAsync(["ghostty", "--class=popup.term", "-e", "sshs", "--vim"]).catch(console.error)
      }>
        <label label="" />
      </button>
      <Gtk.Revealer
        revealChild={connected}
        transitionType={Gtk.RevealerTransitionType.SLIDE_LEFT}
        transitionDuration={300}
      >
        <box>
          <button class="ssh-item" onClicked={() =>
            execAsync(["ghostty", "--class=popup.term", "-e", "sshs", "--vim"]).catch(console.error)
          }>
            <label label={info(i => ` ${i.user} / `)} />
          </button>
          <button class="ssh-item" onClicked={() =>
            execAsync(["ghostty", "--class=popup.term", "-e", "sshs", "--vim"]).catch(console.error)
          }>
            <label label={info(i => ` ${i.host} / `)} />
          </button>
          <button class="ssh-item" onClicked={() =>
            execAsync(["ghostty", "--class=popup.term", "-e", "sshs", "--vim"]).catch(console.error)
          }>
            <label label={info(i => ` ${i.ip}`)} />
          </button>
        </box>
      </Gtk.Revealer>
    </box>
  )
}
