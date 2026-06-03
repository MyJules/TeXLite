import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Button {
    id: root

    flat: true
    Layout.fillWidth: true
    implicitHeight: 36
    leftPadding: 12
    rightPadding: 12
    Material.roundedScale: Material.ExtraSmallScale

    readonly property bool menuHighlighted: down || hovered || visualFocus

    background: Rectangle {
        radius: 8
        color: root.down
               ? "#3a3a3a"
               : root.checked
                 ? (root.hovered ? "#303030" : "#292929")
                 : root.hovered
                   ? "#262626"
                   : "transparent"
        border.color: root.checked
                      ? "#5c5c5c"
                      : root.visualFocus
                        ? "#4b4b4b"
                        : "transparent"
        border.width: 1
    }

    contentItem: Item {
        anchors.fill: parent

        Label {
            id: menuText
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.right: checkMark.visible ? checkMark.left : parent.right
            anchors.rightMargin: checkMark.visible ? 10 : 14
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            color: !root.enabled
                   ? "#7f7f7f"
                   : root.menuHighlighted || root.checked
                     ? "#ffffff"
                     : "#e6e6e6"
            font.pointSize: 10
            font.weight: root.checked ? Font.DemiBold : Font.Medium
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Label {
            id: checkMark
            visible: root.checkable
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: root.checked ? "✓" : ""
            color: !root.enabled ? "#7f7f7f" : "#f5f5f5"
            font.pointSize: 10
            font.bold: true
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }
    }
}
