import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    radius: 4
    clip: true
    color: "#262626"

    BusyIndicator {
        anchors.fill: parent
        transform: Scale {
            origin.x: root.width / 2
            origin.y: root.height / 2
            xScale: 0.7
            yScale: 0.7
        }
    }
}
