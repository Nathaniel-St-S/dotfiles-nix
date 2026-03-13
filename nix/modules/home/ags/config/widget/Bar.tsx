import app from "ags/gtk4/app"
import { Astal } from "ags/gtk4"
import Workspaces from "./Workspaces"
import Mpris from "./Mpris"
import Clock from "./Clock"
import Audio from "./Audio"
import Bluetooth from "./Bluetooth"
import Battery from "./Battery"
import Network from "./Network"
import Hardware from "./Hardware"
import Tray from "./Tray"
import Notifications from "./Notifications"
import Ssh from "./Ssh"

export default function Bar(monitor: number = 0) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  return (
    <window
      visible
      name={`bar-${monitor}`}
      namespace="bar"
      class="bar"
      monitor={monitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      heightRequest={32}
      application={app}
      $={(self: any) => {
        print("Bar: $ callback, realized =", self.get_realized(), "visible =", self.visible)
        self.connect("map", () => print("Bar: MAP — on screen"))
        self.connect("unmap", () => print("Bar: UNMAP — off screen"))
        self.connect("notify::default-height", () => print("Bar: height changed to", self.get_height()))
        // Force the window to present itself to the compositor
        self.present()
        print("Bar: present() called")
        // Check size after a short delay once GTK has done layout
        import("ags/time").then(({ timeout }) => {
          timeout(500, () => {
            print("Bar: 500ms later — mapped =", self.get_mapped(), "width =", self.get_width(), "height =", self.get_height())
          })
        })
      }}
    >
      <centerbox>
        <box $type="start" class="bar-left">
          <Workspaces />
          <Mpris />
        </box>
        <box $type="center" class="bar-center">
          <Clock />
          <Audio />
          <Bluetooth />
          <Battery />
          <Network />
          <Hardware />
          <Tray />
          <Notifications />
        </box>
        <box $type="end" class="bar-right">
          <Ssh />
        </box>
      </centerbox>
    </window>
  )
}
