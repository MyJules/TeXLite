import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Row {
    id: root

    spacing: 10
    leftPadding: 5

    signal showHidePDFClicked
    property alias footerText: text.text

    Text {
        id: text
        anchors.verticalCenter: parent.verticalCenter
        font.pointSize: 10
        height: 20
        text: "No File"
        color: "white"
    }

    ToolButton {
        flat: true
        font.pointSize: 10
        height: 30
        text: "Show/Hide PDF"

        onClicked: showHidePDFClicked()
    }
}
