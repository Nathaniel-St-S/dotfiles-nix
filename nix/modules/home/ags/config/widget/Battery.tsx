import Battery from "gi://AstalBattery"
import { createBinding, createComputed } from "ags"

const ICONS = [" ", " ", " ", " ", " "]

function batteryIcon(pct: number): string {
  return ICONS[Math.min(Math.floor(pct / 20), 4)]
}

export default function BatteryWidget() {
  print("Battery: init")
  const bat       = Battery.get_default()
  print("Battery: got default:", bat)
  const isPresent = createBinding(bat, "is-present")
  const charging  = createBinding(bat, "charging")
  const pct       = createBinding(bat, "percentage")
  print("Battery: bindings created")

  const label = createComputed(() => {
    const p = Math.round(pct() * 100)
    return charging() ? ` ${p}%` : `${batteryIcon(p)} ${p}%`
  })

  print("Battery: returning JSX")
  return (
    <box visible={isPresent}>
      <label
        class={charging(c => c ? "battery charging" : "battery")}
        label={label}
      />
    </box>
  )
}
