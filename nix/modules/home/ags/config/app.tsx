import app from "ags/gtk4/app"
import { readFile } from "ags/file"
import GLib from "gi://GLib"
import Gdk from "gi://Gdk"

print("importing widgets...")
import Bar from "./widget/Bar"
print("Bar ok")

app.start({
  main() {
    print("=== main() started ===")

    // Load CSS so bar is actually visible
    try {
      app.reset_css()
      app.apply_css("window.bar { background-color: #222; min-height: 32px; } label { color: white; font-size: 12px; }")
      print("CSS: fallback applied")
    } catch(e) {
      print("CSS error:", e)
    }

    const display = Gdk.Display.get_default()
    const n = display ? display.get_monitors().get_n_items() : 1
    print("Monitor count:", n)

    for (let i = 0; i < n; i++) {
      print("Calling Bar(" + i + ")")
      try {
        Bar(i)
      } catch(e) {
        print("Bar() threw:", e)
      }
    }

    print("=== done ===")
  },
})
