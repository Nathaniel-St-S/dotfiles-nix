import Bluetooth from "gi://AstalBluetooth"
import { createBinding, createComputed } from "ags"
import { execAsync } from "ags/process"

export default function BluetoothWidget() {
  print("Bluetooth: init")
  const bt = Bluetooth.get_default()
  print("Bluetooth: got default:", bt)
  const isPowered = createBinding(bt, "is-powered")
  const devices   = createBinding(bt, "devices")
  print("Bluetooth: bindings created")

  const icon = createComputed(() => {
    if (!isPowered()) return ""
    const connected = devices().some(d => d.connected)
    return connected ? "" : ""
  })

  print("Bluetooth: returning JSX")
  return (
    <button
      class={isPowered(on => on ? "bluetooth on" : "bluetooth off")}
      onClicked={() =>
        execAsync(["ghostty", "--class=popup.term", "-e", "bluetui"]).catch(console.error)
      }
    >
      <label label={icon} />
    </button>
  )
}
