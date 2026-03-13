import Battery from "gi://AstalBattery"
import { createBinding, createComputed } from "ags"

const ICONS = [" ", " ", " ", " ", " "]

function batteryIcon(pct: number): string {
  return ICONS[Math.min(Math.floor(pct / 20), 4)]
}

export default function BatteryWidget() {
  const bat       = Battery.get_default()
  const isPresent = createBinding(bat, "is-present")
  const charging  = createBinding(bat, "charging")
  const pct       = createBinding(bat, "percentage") // 0–1 float

  const label = createComputed(() => {
    const p = Math.round(pct() * 100)
    return charging() ? ` ${p}%` : `${batteryIcon(p)} ${p}%`
  })

  return (
    <box visible={isPresent}>
      <label
        class={charging(c => c ? "battery charging" : "battery")}
        label={label}
      />
    </box>
  )
}
