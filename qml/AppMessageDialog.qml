import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Dialog {
    id: root

    property string text: ""
    property int buttons: Dialog.Ok

    modal: true
    anchors.centerIn: Overlay.overlay
    width: 460
    padding: 0
    closePolicy: Popup.NoAutoClose
    Material.roundedScale: Material.ExtraSmallScale

    background: Rectangle {
        radius: 12
        color: "#1d1d1d"
        border.color: "#3a3a3a"
        border.width: 1
    }

    header: Rectangle {
        implicitHeight: 52
        color: "#242424"
        radius: 12
        topLeftRadius: 12
        topRightRadius: 12
        bottomLeftRadius: 0
        bottomRightRadius: 0
        border.color: "#3a3a3a"
        border.width: 1

        Label {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            verticalAlignment: Text.AlignVCenter
            text: root.title
            color: "#f0f0f0"
            font.pointSize: 12
            font.bold: true
            elide: Text.ElideRight
        }
    }

    contentItem: ColumnLayout {
        width: 420
        spacing: 0

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: 18
            Layout.rightMargin: 18
            Layout.topMargin: 18
            Layout.bottomMargin: 18
            text: root.text
            color: "#d0d0d0"
            font.pointSize: 10.5
            wrapMode: Text.WordWrap
        }
    }

    footer: DialogButtonBox {
        standardButtons: root.buttons
        spacing: 10
        padding: 14
        alignment: Qt.AlignRight

        background: Rectangle {
            color: "#1d1d1d"
            border.color: "#3a3a3a"
            border.width: 1
            radius: 12
            topLeftRadius: 0
            topRightRadius: 0
            bottomLeftRadius: 12
            bottomRightRadius: 12
        }

        delegate: Button {
            flat: true
            Material.roundedScale: Material.ExtraSmallScale

            background: Rectangle {
                radius: 8
                color: down ? "#343434" : hovered ? "#2b2b2b" : "transparent"
                border.color: "#4a4a4a"
                border.width: 1
            }

            contentItem: Label {
                text: parent.text
                color: "#f0f0f0"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 10
            }
        }

        onAccepted: root.accept()
        onRejected: root.reject()
    }
}
