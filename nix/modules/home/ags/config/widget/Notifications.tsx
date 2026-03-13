import { createPoll } from "ags/time"
import { execAsync, exec } from "ags/process"

type SwayNCState = {
  text: string
  class: string
}

const ICONS: Record<string, string> = {
  "notification":               "",
  "none":                       "",
  "dnd-notification":           "",
  "dnd-none":                   "",
  "inhibited-notification":     "",
  "inhibited-none":             "",
  "dnd-inhibited-notification": "",
  "dnd-inhibited-none":         "",
}

export default function Notifications() {
  const state = createPoll<SwayNCState>(
    { text: "", class: "none" },
    2000,
    () => {
      try {
        return JSON.parse(exec(["swaync-client", "-swb"])) as SwayNCState
      } catch {
        return { text: "", class: "none" }
      }
    }
  )

  return (
    <button
      class="notifications"
      onClicked={() =>
        execAsync(["swaync-client", "-t", "-sw"]).catch(console.error)
      }
    >
      <label label={state(s => ICONS[s.class] ?? "")} />
    </button>
  )
}
