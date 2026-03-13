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
      class="bar"
      monitor={monitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
    >
      <centerbox>

        <box class="bar-left">
          <Workspaces />
          <Mpris />
        </box>

        <box class="bar-center">
          <Clock />
          <Audio />
          <Bluetooth />
          <Battery />
          <Network />
          <Hardware />
          <Tray />
          <Notifications />
        </box>

        <box class="bar-right">
          <Ssh />
        </box>

      </centerbox>
    </window>
  )
}
