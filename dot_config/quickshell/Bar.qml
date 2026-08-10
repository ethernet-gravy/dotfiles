import Quickshell // for PanelWindow
import Quickshell.Io // for Process
import QtQuick // for Text
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import Quickshell.Wayland

import "config.js" as Conf

PanelWindow {
    id: win
    anchors {
        top: true
        left: true
        right: true
    }
    /* margins { */
    /*     top: 12  */
    /*     left: 12  */
    /*     right: 12  */
    /* } */
    property var wsData: []
    property var focusedScreen
    property var barHeight: 30
    property string pomoStatusLine: ""
    screen: {
        for (const s of Quickshell.screens) {
            if (s.name === win.focusedScreen) return s;
        }
        return Quickshell.screens[0];
    }

    required property var history
    property var notifCenterVisible: false
    property var pomoVisible: false
    property int x: 0
    property int y: 0

    Rectangle { anchors.fill: parent; color: Conf.colors.bg }
    

    implicitHeight: barHeight

    NotificationCenter {
        history: win.history
        bar: win
        x: win.x
        y: win.y
        visible: notifCenterVisible
    }

    RowLayout {
        id: left_layout

        spacing: 4
        anchors {
            left: parent.left
            bottom: parent.bottom
            top: parent.top
            leftMargin: 20
        }

        Niri {
        }

    RowLayout{
        Repeater {
            model: win.wsData
            Rectangle {
                required property var modelData
                readonly property bool foc: modelData.focused
                readonly property bool occ: modelData.occupied
                readonly property int wid: modelData.idx

                width: foc ? 60: 20; height: 20; radius: 20
                //border.width: 2
                //border.color: foc? "#AA3731" : "#325CC0"


                color: foc? Conf.colors.redSubtle :  Conf.colors.blueSubtle

                StyledText {
                    anchors.centerIn: parent
                    text: wid
                    color: foc ? Conf.colors.red : Conf.colors.blue
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: Qt.createQmlObject(
                        'import Quickshell.Io; Process{command:["niri","msg","action","focus-workspace","' + wid + '"];running:true}',
                        win, "fw")
                }
            }
        }
    }
    }

    RowLayout {
        id: middle_layout
        spacing: 8
        anchors {
            left: left_layout.right
            right: right_layout.left
            bottom: parent.bottom
            centerIn: parent
        }
        Button {
            id: pomodoroButton
            text: (pomoStatusLine === "") ? "🕑️" :  pomoStatusLine

    
            font.pointSize: 18
            checkable: true
            background: Rectangle {
                color: Conf.colors.bgSubtle    
            }
            onToggled: {
                pomoVisible = pomodoroButton.checked;
            }

        }
        ClockWidget {
            id: clock
            Layout.alignment: Qt.AlignLeft
        }



    }

    Pomodoro{
        bar: win
        cardVisible: pomoVisible
    }


    RowLayout {
        id: right_layout
        anchors {
            bottom: parent.bottom
            right: parent.right
            //rightMargin: 20
        }

        Button {
            id: notifToggle
            text: " "
            palette.buttonText: Conf.colors.fg
            checkable: true
            background: Rectangle {
                id: notifToggleBG
                border.color: Conf.colors.blue
                border.width: 0
                color: Conf.colors.bgSubtle
                radius: 25
                implicitWidth: 25
                implicitHeight: 25
            }
            onToggled: {
                notifCenterVisible = notifToggle.checked;
                notifToggleBG.border.width = (notifToggle.checked) ? 1 : 0;
                notifToggleBG.color = (notifToggle.checked)
                    ? Conf.colors.blueSubtle : Conf.colors.bgSubtle;
                notifToggle.palette.buttonText = (notifToggle.checked)
                    ?  Conf.colors.blue : Conf.colors.fg 
                var buttonPos  = notifToggle.mapToItem(null, 0, 0);
                win.x = buttonPos.x;
                win.y = buttonPos.y; 
            }
        }

        Rectangle {
            id: rect
            color: Conf.colors.magentaSubtle
            radius: 2
            height: win.barHeight
            implicitWidth: systray.implicitWidth + 20
            RowLayout {
                id: systray
                anchors.centerIn: parent
                Repeater {
                    model: SystemTray.items

                    delegate: Item {
                        id: trayItem
                        width: barHeight * 0.5
                        height: barHeight * 0.5

                        IconImage {
                            id: trayIcon
                            anchors {
                                fill: parent
                            }
                            source: modelData.icon
                        }

                        MouseArea {
                            id: trayItemArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                            onClicked: mouse => {
                                if (mouse.button === Qt.LeftButton)
                                    modelData.activate();
                                else if (mouse.button === Qt.MiddleButton)
                                    modelData.secondaryActivate();
                                else {
                                    /* I don't know why this works, I copied this gp line from DMS */
                                    const gp = trayItemArea.mapToGlobal(mouse.x, mouse.y)
                                    modelData.display(win, gp.x, gp.y)
                                }
                            }
                        }
                    }
                }

            }

        }
    }
}
