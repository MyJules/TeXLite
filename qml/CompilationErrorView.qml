import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Item {
    property alias errorString: errorText.text

    Text {
        id: errorText

        color: "red"
        anchors.fill: parent
        font.pointSize: 12
    }
}
