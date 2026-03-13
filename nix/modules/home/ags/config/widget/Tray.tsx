import Tray from "gi://AstalTray"
import { createBinding } from "ags"
import { For } from "ags"

export default function SysTray() {
  const tray  = Tray.get_default()
  const items = createBinding(tray, "items")

  return (
    <box class="tray">
      <For each={items}>
        {(item) => {
          const gicon   = createBinding(item, "gicon")
          const tooltip = createBinding(item, "tooltip-markup")

          return (
            <menubutton
              class="tray-item"
              tooltipMarkup={tooltip}
              menuModel={createBinding(item, "menu-model")()}
              usePopover={false}
            >
              <image gicon={gicon()} pixelSize={20} />
            </menubutton>
          )
        }}
      </For>
    </box>
  )
}
