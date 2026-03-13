import Wp from "gi://AstalWp"
import { createBinding, createComputed } from "ags"
import { execAsync } from "ags/process"

function volumeIcon(pct: number, muted: boolean): string {
  if (muted || pct === 0) return " "
  if (pct < 34) return " "
  if (pct < 67) return " "
  return " "
}

export default function Audio() {
  print("Audio: init")
  const wp = Wp.get_default()
  print("Audio: Wp.get_default() =", wp)
  const audio = wp.audio
  print("Audio: audio =", audio)
  const speaker = createBinding(audio, "default-speaker")
  print("Audio: binding created")

  const info = createComputed(() => {
    const s = speaker()
    if (!s) return { icon: " ", label: "—" }
    const pct  = Math.round(s.volume * 100)
    const icon = volumeIcon(pct, s.mute)
    return { icon, label: `${icon} ${pct}%` }
  })

  print("Audio: returning JSX")
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
