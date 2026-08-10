//@ pragma UseQApplication
import Quickshell
import QtQuick

Scope {
    ListModel { id: history }
    ListModel { id: workspaces }

    Bar { id: win; history: history }
    Notifications {id: notifs; history: history }

}
