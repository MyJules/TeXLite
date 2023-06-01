import QtQuick

Row {
    spacing: 10
    leftPadding: 5

    property alias footerText: text.text

    Text {
        id: text
        anchors.verticalCenter: parent.verticalCenter
        font.pointSize: 10
        height: 20
        text: "No File"
        color: "white"
    }
}
