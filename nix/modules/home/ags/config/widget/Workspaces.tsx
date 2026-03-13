import { createPoll } from "ags/time"
import { execAsync } from "ags/process"
import { For } from "ags"

type Workspace = {
  id: number
  idx: number
  name: string | null
  output: string
  is_active: boolean
  is_focused: boolean
}

export default function Workspaces() {
  // Poll niri's JSON IPC for workspace state.
  const workspaces = createPoll<Workspace[]>([], 500, async () => {
    const out = await execAsync(["niri", "msg", "--json", "workspaces"])
    return JSON.parse(out) as Workspace[]
  })

  const sorted = workspaces(wss => [...wss].sort((a, b) => a.idx - b.idx))

  return (
    <box class="workspaces">
      <For each={sorted}>
        {(ws) => (
          <button
            class={ws.is_focused ? "workspace active" : "workspace"}
            onClicked={() =>
              execAsync(["niri", "msg", "action", "focus-workspace", String(ws.idx)])
            }
          >
            {/* label is invisible — workspace buttons are styled as dots via CSS */}
            <label label="" />
          </button>
        )}
      </For>
    </box>
  )
}
