
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Scope {
    id: root

    //readonly property string niriSocket: Quickshell.env("NIRI_SOCKET")
    Process {
        id: wsStream
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    var e = JSON.parse(data)
                    if (e.WorkspacesChanged)       root.parseWs(e.WorkspacesChanged.workspaces)
                    else if (e.WorkspaceActivated) wsQuery.running = true
                } catch(_) {}
            }
        }
        onRunningChanged: if (!running) wsRestart.start()
    }
    Timer { id: wsRestart; interval: 1500; onTriggered: wsStream.running = true }

    Process {
        id: wsQuery
        command: ["niri", "msg", "--json", "workspaces"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var p = JSON.parse(data)
                    var list = (p.Ok && p.Ok.Workspaces) ? p.Ok.Workspaces
                        : Array.isArray(p) ? p
                        : (p.Ok && Array.isArray(p.Ok)) ? p.Ok : null
                    if (list) root.parseWs(list)
                } catch(_) {}
            }
        }
        Component.onCompleted: running = true
    }

    function parseWs(list) {
        if (!Array.isArray(list)) return
        var a = []
        for (var i = 0; i < list.length; i++) {
            var w = list[i]
            a.push({ idx: w.idx !== undefined ? w.idx : i+1,
                     focused: w.is_focused,
                     occupied: w.active_window_id != null })
            if (w.is_focused)
                win.focusedScreen = w.output;
        }
        a.sort(function(x, y) { return x.idx - y.idx })
        win.wsData = a
    }



}
