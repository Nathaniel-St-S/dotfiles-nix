import Mpris from "gi://AstalMpris"
import { createBinding, createComputed } from "ags"
import { With } from "ags"

export default function MprisWidget() {
  print("Mpris: init")
  const mpris = Mpris.get_default()
  print("Mpris: got default:", mpris)
  const players = createBinding(mpris, "players")
  print("Mpris: binding created")
  const player = createComputed(() => players()[0] ?? null)

  print("Mpris: returning JSX")
  return (
    <box class="mpris">
      <With value={player}>
        {(p) => {
          if (!p) return <box visible={false} />
          const status = createBinding(p, "playback-status")
          const artist = createBinding(p, "artist")
          const title  = createBinding(p, "title")
          const label = createComputed(() => {
            const a    = artist() ?? ""
            const t    = title()  ?? ""
            const text = a && t ? `${a} - ${t}` : t || a
            return text.length > 50 ? text.slice(0, 49) + "…" : text
          })
          return (
            <label
              class={status(s =>
                s === Mpris.PlaybackStatus.PAUSED ? "mpris-label paused" : "mpris-label"
              )}
              label={label}
            />
          )
        }}
      </With>
    </box>
  )
}
