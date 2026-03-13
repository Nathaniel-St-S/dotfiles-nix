import { createPoll } from "ags/time"
import { createState } from "ags"
import { readFile, } from "ags/file"
import { execAsync } from "ags/process"
import Gtk from "gi://Gtk"

// ── CPU usage via /proc/stat ─────────────────────────────────────────────────

let prevIdle  = 0
let prevTotal = 0

function readCpu(): number {
  const line   = readFile("/proc/stat").split("\n")[0]
  const fields = line.split(/\s+/).slice(1).map(Number)
  const idle   = fields[3] + (fields[4] ?? 0)  // idle + iowait
  const total  = fields.reduce((a, b) => a + b, 0)

  const diffIdle  = idle  - prevIdle
  const diffTotal = total - prevTotal
  prevIdle  = idle
  prevTotal = total

  return diffTotal === 0 ? 0 : Math.round((1 - diffIdle / diffTotal) * 100)
}

// ── Memory usage via /proc/meminfo ───────────────────────────────────────────

function readMem(): number {
  const info  = readFile("/proc/meminfo")
  const get   = (key: string) => parseInt(info.match(new RegExp(`^${key}:\\s+(\\d+)`, "m"))?.[1] ?? "0")
  const total = get("MemTotal")
  const avail = get("MemAvailable")
  return total === 0 ? 0 : Math.round((1 - avail / total) * 100)
}

// ── Disk usage ───────────────────────────────────────────────────────────────

function openBtop() {
  execAsync(["ghostty", "--class=popup.term", "-e", "btop"]).catch(console.error)
}

// ── Widget ───────────────────────────────────────────────────────────────────

export default function Hardware() {
  const [open, setOpen] = createState(false)

  const cpu  = createPoll(0,   2000, readCpu)
  const mem  = createPoll(0,   2000, readMem)
  const disk = createPoll("0", 10000, async () => {
    const out = await execAsync(["df", "--output=pcent", "/"])
    return out.trim().split("\n").at(-1)?.trim().replace("%", "") ?? "0"
  })

  return (
    <box class="hardware">

      {/* The icon button toggles the drawer */}
      <button class="hardware-icon" onClicked={() => setOpen(v => !v)}>
        <label label="" />
      </button>

      <Gtk.Revealer
        revealChild={open}
        transitionType={Gtk.RevealerTransitionType.SLIDE_LEFT}
        transitionDuration={300}
      >
        <box>
          <button class="hardware-item" onClicked={openBtop}>
            <label label={disk(d => ` ${d}% `)} />
          </button>
          <button class="hardware-item" onClicked={openBtop}>
            <label label={cpu(c => `/  ${c}% `)} />
          </button>
          <button class="hardware-item" onClicked={openBtop}>
            <label label={mem(m => `/  ${m}% `)} />
          </button>
        </box>
      </Gtk.Revealer>

    </box>
  )
}
