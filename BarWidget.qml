import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root
  moduleName: "maiosx.omarchy-version"

  property string label: "Omarchy"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  // "omarchy 4.5.0rc2-1"  ->  "Omarchy 4.5.0rc2-1"
  function parse(raw) {
    const t = (raw || "").trim()
    if (t === "") return
    const m = t.match(/^omarchy\s+(\S+)/i)
    root.label = m ? "Omarchy " + m[1] : (/^omarchy/i.test(t) ? t : "Omarchy " + t)
  }

  Process {
    id: versionProc
    // pacman gives the full pkgver-pkgrel; fall back to the omarchy CLI.
    command: ["sh", "-c", "pacman -Q omarchy 2>/dev/null || omarchy version 2>/dev/null"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root.parse(text)
    }
  }

  function refresh() {
    if (!versionProc.running) versionProc.running = true
  }

  // Opens fastfetch in the default terminal and keeps the window open
  // until a key is pressed (fastfetch exits immediately otherwise).
  function openFastfetch() {
    Quickshell.execDetached([
      "xdg-terminal-exec", "sh", "-c",
      "fastfetch; printf '\\n'; read -rsn1 -p 'Press any key to close...'"
    ])
  }

  // Picks up updates without needing a shell restart.
  Timer {
    interval: 30 * 60 * 1000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.label
    tooltipText: "Omarchy build (click for fastfetch)"
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.LeftButton) root.openFastfetch()
    }
  }
}
