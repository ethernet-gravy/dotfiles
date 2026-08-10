import "config.js" as Conf
import QtQuick
import Quickshell.Widgets

WrapperItem{
    id: root
    required property string text
    property color color: Conf.colors.fg
    property int pointSize: Conf.font.size
    property var elide: Text.ElideNone
    property bool bold: false
    property var wrapMode: Text.NoWrap
    property var align: Text.AlignLeft
    property var margins: 0

    child: WrapperRectangle {
        color: "transparent"
        margin: root.margins
        Text {
            anchors.margins: root.margins
            text: root.text
            color: root.color
            font.family: Conf.font.font
            font.pointSize: root.pointSize
            elide: root.elide
            font.bold: root.bold
            wrapMode: root.wrapMode
            horizontalAlignment: root.align
        }
    }
}
