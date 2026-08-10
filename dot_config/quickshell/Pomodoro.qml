import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Wayland
import "config.js" as Conf

Scope {
    id: root

    property bool daemonRunning: false
    property bool pomoStarted: false
    property bool pomoResumed: false
    property string status: (daemonRunning) ? "Daemon is running" : "Daemon is not running"
    property double percentComplete: 0.0
    required property bool cardVisible
    required property var bar



    Process {
        id: reportStatus
        command: ["notify-send", "Pomodoro", status]
        running: false 
    }


    Process {
        id: pollStatus
        command: ["tomat", "status"]
        running: false
        stdout: SplitParser  {
            onRead: data => {
                console.log("Tomat polled");
                try {
                    var e = JSON.parse(data);
                    const a = e.text.split(" ");
                    percentComplete = e.percentage / 100;
                    status = e.tooltip;
                    win.pomoStatusLine =  (pomoStarted) ? a[0] : ""
                    if (e.class === "work-paused" || e.class === "break-paused")
                        pomoResumed = false;
                }
                catch(_) {}
            }
        }
    }

    Timer {
        id: tomatPollingTimer
        interval: 1000
        repeat: true
        running: pomoResumed
        triggeredOnStart: true
        onTriggered: {
            pollStatus.running = true;
        }
    }




 //   start the daemon
    Process {
        id: startDaemon
        command: ["tomat", "daemon", "start"]
        running: true
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0)
            {
                daemonRunning = true;
                pollStatus.running = true;
            }
        }
        
    }

 //   stop the daemon
    Process {
        id: stopDaemon
        command: ["sh", "-c", "tomat stop && tomat daemon stop"]
        running: false
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                daemonRunning = false;
                pomoStarted = false;
                pomoResumed = false;
                win.pomoStatusLine = "";
            }
        }
        
    }


    Process {
        id: startPomo
        command: pomoStarted ? ["tomat", "resume"] : ["tomat", "start"]  
        running: false
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) 
                if (!pomoStarted) pomoStarted = true;
            pomoResumed = true;

        }
        
    }

    Process {
        id: pausePomo
        command:  ["tomat", "pause"]  
        running: false
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) 
                pomoResumed = false;
        }
        
    }

    Process {
        id: skipPomo
        command:  ["tomat", "skip"]  
        running: false
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) { 
                pomoResumed = false;
                pollStatus.running = true;
            }
        }
        
    }

    Process {
        id: restartPomo
        command:  ["tomat", "stop"]  
        running: false
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                pomoResumed = false;
                pomoStarted = false;
                pollStatus.running = true;
            }
        }


    }





//    progress bars are just rectangles
    

    PopupWindow {
        id: window
        anchor {
            window: root.bar
            rect.x: (root.bar.screen.width / 2) - (window.implicitWidth / 2 )
            rect.y: 40

        }
        implicitWidth: 400
        implicitHeight: 100
        visible: cardVisible

        Rectangle {
            visible: !daemonRunning
            anchors.fill: parent
            Button {
                anchors.centerIn: parent
                text: "Start Daemon"
                onClicked: {
                    startDaemon.running = true;
                }
            }
        }

        Rectangle {
            visible: daemonRunning
            anchors.fill: parent
            color: Conf.colors.bg
            border.width: 2
            ColumnLayout{
                anchors.fill: parent
                anchors.topMargin: 10
                Rectangle {
                    visible: pomoStarted
                    Layout.alignment: Qt.AlignCenter
                    id: progressBg
                    color: Conf.colors.redSubtle
                    border.color: Conf.colors.red
                    implicitWidth: window.implicitWidth * 0.8
                    implicitHeight: 9
                    border.width: 2
                    Rectangle {
                        id: progressFg
                        anchors {
                            left: progressBg.left
                            leftMargin: 2
                            verticalCenter: parent.verticalCenter
                        }
                        color: Conf.colors.red
                        implicitWidth: parent.implicitWidth * percentComplete
                        implicitHeight: 5
                    }

                }

                RowLayout {
                    //anchors.fill: parent
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    Layout.alignment: Qt.AlignCenter

                    /* anchors.leftMargin: 20 */
                    /* anchors.rightMargin: 10 */

                    Button {
                        text: "⏹️"
                        font.pointSize: 18
                        background: Rectangle {
                            color: Conf.colors.bgSubtle
                            border.width: 2
                            implicitWidth: window.implicitWidth * 0.14
                            implicitHeight: 40
                        }
                        onClicked: {
                            if (!stopDaemon.running)
                                stopDaemon.running = true; 
                        }
                    }

                    Button {
                        text: " "
                        font.pointSize: 17
                        background: Rectangle {
                            color: Conf.colors.bgSubtle
                            border.width: 2
                            implicitWidth: window.implicitWidth * 0.14
                            implicitHeight: 40
                        }
                        onClicked: {
                            if (!reportStatus.running)
                                reportStatus.running = true;
                        }

                    }

                    Button {
                        text: (pomoResumed) ? "⏸️" : "▶️"
                        font.pointSize: 18
                        background: Rectangle {
                            color: Conf.colors.bgSubtle
                            border.width: 2
                            implicitWidth: window.implicitWidth * 0.14
                            implicitHeight: 40
                        }
                        onClicked: {
                            if (!pomoResumed){
                                startPomo.running = true
                            }
                            else {
                                pausePomo.running = true
                            }
                        }

                    }

                    Button {
                        text: "⏩️"
                        font.pointSize: 18
                        background: Rectangle {
                            color: Conf.colors.bgSubtle
                            border.width: 2
                            implicitWidth: window.implicitWidth * 0.14
                            implicitHeight: 40
                        }
                        onClicked: {
                            skipPomo.running = true; 
                        }

                    }

                    Button {
                        text: "🔁"
                        font.pointSize: 18
                        background: Rectangle {
                            color: Conf.colors.bgSubtle
                            border.width: 2
                            implicitWidth: window.implicitWidth * 0.14
                            implicitHeight: 40
                        }
                        onClicked: {
                            restartPomo.running = true;
                        }

                    }
                }
            }
        }
    }


}
