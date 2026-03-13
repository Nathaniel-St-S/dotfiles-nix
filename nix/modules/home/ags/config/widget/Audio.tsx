import Wp from "gi://AstalWp"
import { createBinding, createComputed } from "ags"
import { execAsync } from "ags/process"

function volumeIcon(pct: number, muted: boolean): string {
  if (muted || pct === 0) return ""
  if (pct < 34) return ""
  if (pct < 67) return " "
  return " "
}

export default function Audio() {
  const audio   = Wp.get_default().audio
  const speaker = createBinding(audio, "default-speaker")

  // Derive volume/mute from the current speaker.
  // The speaker object itself changes when the default output changes.
  const info = createComputed(() => {
    const s = speaker()
    if (!s) return { icon: " ", label: "—" }
    const pct  = Math.round(s.volume * 100)
    const icon = volumeIcon(pct, s.mute)
    return { icon, label: `${icon} ${pct}%` }
  })

  return (
    <button
      class="audio"
      onClicked={() =>
        execAsync(["ghostty", "--class=popup.term", "-e", "wiremix"]).catch(console.error)
      }
    >
      <label label={info(i => i.label)} />
    </button>
  )
}
