import QtQuick
import QtQuick
import Quickshell
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Wayland
import "config.js" as Conf
Scope {
    id: root
    required property var history
    required property bool visible
    required property var bar
    required property int x
    required property int y
    PopupWindow {
        id: window
        anchor {
            window: root.bar
            rect.x: {
                if ( (root.x + window.implicitWidth) >= root.bar.screen.width ) {
                    return root.bar.screen.width - window.implicitWidth - 10
                }
                else {
                    root.x
                }
            }
            rect.y: root.y + 40
        }
        implicitWidth: 300
        implicitHeight: 300
        visible: root.visible 

        Rectangle{
            anchors.fill: parent
            border.width: 2
            border.color: Conf.colors.blue
            color: Conf.colors.bg
            ScrollView{
                anchors.fill: parent
                anchors.margins: 20
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ColumnLayout {
                    anchors.fill: parent

                    spacing: 10
                    StyledText {
                        bold: true
                        text: "Notifications: "
                    }

                Repeater {
                    model: root.history
                    delegate: Rectangle {
                        id: centerCard
                        required property var modelData
                        implicitWidth: window.implicitWidth - 40
                        implicitHeight: colLayout.implicitHeight + 10
                        color: Conf.colors.bg
                        border.width: 2
                        border.color: Conf.colors.green
                        ColumnLayout {
                            id: colLayout
                            anchors.fill: parent
                            //spacing: 50
                            RowLayout {
                                Layout.leftMargin: 10
                                Layout.rightMargin: 10
                                Layout.preferredWidth: centerCard.implicitWidth - 20
                                //spacing: 50
                                StyledText {
                                    text: modelData.appName
                                    Layout.fillWidth: true
                                    bold: true
                                    elide: Text.ElideRight
                                    color: Conf.colors.magenta
                                }
                                StyledText {
                                    text: modelData.summary
                                    Layout.fillWidth: true
                                    bold: true
                                    elide: Text.ElideRight
                                    color: Conf.colors.blue
                                    align: Text.AlignRight
                                }
                            }
                            StyledText {
                                text: modelData.body
                                margins: 10
                                wrapMode: Text.WordWrap
                                Layout.preferredWidth: centerCard.implicitWidth - 20
                            }
                        }
                    }
                }
                }
            }
        }
    }
}
