import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import QtQuick.Layouts
import Quickshell.Wayland
import "config.js" as Conf
Scope {
    id: root 

    required property var history

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: n =>{
            n.tracked = true;
            history.insert(0, {
                summary: n.summary,
                body: n.body,
                appName: n.appName,
                urgency: n.urgency,
                time: Qt.formatDateTime(new Date(), "HH:mm")
            })
        }
    }


    PanelWindow {
        anchors {
            top: true
            right: true
        }
        margins
        {
            top: 20 + 30
            right: 20
        }
        implicitHeight: column.implicitHeight
        implicitWidth: 380
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        ColumnLayout {
            id: column
            width: parent.width
            spacing: 10
            Repeater {
                model: server.trackedNotifications
                delegate: Rectangle {
                    id: card
                    required property var modelData
                    Layout.fillWidth: true
                    //Layout.preferredHeight: 60
                    Layout.preferredHeight: layout.implicitHeight + 20
                    color: Conf.colors.bg
                    border.width: 2
                    border.color: modelData.urgency === NotificationUrgency.Critical
                        ? Conf.colors.red : Conf.colors.green

                    Timer {
                        running: modelData.urgency !== NotificationUrgency.Critical
                        interval: Conf.notifications.timeout
                        onTriggered: modelData.dismiss()
                    }

                    RowLayout {
                        id: layout
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Image {
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 36
                            Layout.alignment: Qt.AlignTop
                                
                            fillMode: Image.preserveAspectFit
                            visible: source.toString() != ""
                            source: modelData.image || modelData.appIcon || ""
                        }
                        ColumnLayout {
                            id: message
                            StyledText {
                                // heading
                                Layout.fillWidth: true
                                text: modelData.summary
                                elide: Text.ElideRight
                                pointSize: 16
                                bold: true
                                visible: text != ""
                                color: Conf.colors.magenta
                            }
                            StyledText{
                                Layout.fillWidth: true
                                text: modelData.body
                                wrapMode: Text.WordWrap
                                
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: mouse => {
                            modelData.dismiss();
                        }
                    }
                }
            }
        }
    }

    
}
