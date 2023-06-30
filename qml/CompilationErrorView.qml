import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Item {
    property alias errorString: errorText.text

    Rectangle {
        anchors.fill: parent
        radius: 4
        color: "#262626"
        border.color: "#ff4d4d"

        Text {
            id: errorText

            color: "#ff4d4d"
            anchors.fill: parent
            font.pointSize: 12

            leftPadding: 10
            rightPadding: 10
            topPadding: 10
            bottomPadding: 10
        }
    }
}
