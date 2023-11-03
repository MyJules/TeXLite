import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    radius: 4
    clip: true
    color: "#262626"

    BusyIndicator {
        anchors.fill: parent
    }
}
