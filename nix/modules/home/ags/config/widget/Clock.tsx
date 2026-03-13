import { createPoll } from "ags/time"
import { createState } from "ags"
import { execAsync } from "ags/process"
import Gdk from "gi://Gdk"
import Gtk from "gi://Gtk"

export default function Clock() {
  const [extended, setExtended] = createState(false)

  const time = createPoll("", 1000, () => {
    const now = new Date()
    if (extended()) {
      return now.toLocaleTimeString("en-US", {
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
        hour12: false,
        timeZoneName: "short",
      })
    }
    return now.toLocaleTimeString("en-US", {
      hour: "numeric",
      minute: "2-digit",
      hour12: true,
    }) + "  "
  })

  // Right-click opens calcurse; left-click toggles the extended format
  function onRelease(_self: Gtk.Button, event: Gdk.Event) {
    if (event.get_event_type() === Gdk.EventType.BUTTON_RELEASE) {
      const button = (event as Gdk.ButtonEvent).get_button()
      if (button === 3) {
        execAsync(["ghostty", "--class=popup.term", "-e", "calcurse"])
          .catch(console.error)
      }
    }
  }

  return (
    <button class="clock" onClicked={() => setExtended(v => !v)}>
      <label label={time} />
    </button>
  )
}
