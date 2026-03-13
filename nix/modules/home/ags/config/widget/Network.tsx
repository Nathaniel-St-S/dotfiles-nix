import Network from "gi://AstalNetwork"
import { createBinding, createComputed } from "ags"
import { execAsync } from "ags/process"

export default function NetworkWidget() {
  const network = Network.get_default()
  const primary = createBinding(network, "primary")
  const wifi    = network.wifi   // may be null on desktop
  const wired   = network.wired  // may be null on wifi-only devices

  const icon = createComputed(() => {
    switch (primary()) {
      case Network.Primary.WIFI:    return " "
      case Network.Primary.WIRED:   return ""
      default:                      return "Not Connected"
    }
  })

  const tooltip = createComputed(() => {
    switch (primary()) {
      case Network.Primary.WIFI:
        return wifi
          ? `  ${wifi.ssid ?? "Unknown"} (${wifi.strength}%)`
          : "WiFi"
      case Network.Primary.WIRED:
        return wired ? `   ${wired.iface}` : "Ethernet"
      default:
        return "Disconnected"
    }
  })

  return (
    <button
      class="network"
      tooltipText={tooltip}
      onClicked={() =>
        execAsync(["ghostty", "--class=popup.term", "-e", "nmtui"]).catch(console.error)
      }
    >
      <label label={icon} />
    </button>
  )
}
