import app from "ags/gtk4/app"
import { readFile, monitorFile } from "ags/file"
import GLib from "gi://GLib"
import Gdk from "gi://Gdk"
import Bar from "./widget/Bar"
import style from "./style/bar.css"

const walScss = `${GLib.get_home_dir()}/.cache/wal/colors.scss`

// Parse pywal's colors.scss ($name: value;) into GTK @define-color directives.
// GTK CSS does not support :root{} or var() — @define-color is the correct mechanism.
function buildColorCss(): string {
  try {
    const lines = readFile(walScss).split("\n")
    const defines: string[] = []

    for (const line of lines) {
      const match = line.match(/^\$([a-zA-Z0-9_]+):\s*([^;]+);/)
      if (match) {
        const [, name, value] = match
        if (name === "wallpaper") continue
        defines.push(`@define-color ${name} ${value.trim()};`)
      }
    }

    return defines.join("\n")
  } catch {
    return ""
  }
}

function loadStyles() {
  app.reset_css()
  app.apply_css(buildColorCss())
  app.apply_css(style)
}

app.start({
  main() {
    loadStyles()
    monitorFile(walScss, loadStyles)

    // Create a bar for each connected monitor
    const display = Gdk.Display.get_default()
    const n = display ? display.get_n_monitors() : 1
    for (let i = 0; i < n; i++) {
      Bar(i)
    }
  },
})
