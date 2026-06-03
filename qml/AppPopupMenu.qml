import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Popup {
    id: root

    default property alias menuContent: contentColumn.data
    property int menuWidth: 220
    property Item anchorItem: null
    property real edgeMargin: 8
    property real verticalOffset: 6
    property point anchorPosition: Qt.point(0, 0)
    property bool useAnchorPosition: false

    function popupHeight() {
        return Math.max(implicitHeight,
                        (contentItem ? contentItem.implicitHeight : 0) + padding * 2)
    }

    function reposition() {
        const overlay = Overlay.overlay

        if (!anchorItem || !overlay) {
            x = edgeMargin
            y = edgeMargin
            return
        }

        const resolvedWidth = Math.max(width, implicitWidth, menuWidth)
        const resolvedHeight = popupHeight()
        const anchorPoint = useAnchorPosition
            ? anchorItem.mapToItem(overlay, anchorPosition.x, anchorPosition.y)
            : anchorItem.mapToItem(overlay, 0, 0)
        const maxX = Math.max(edgeMargin, overlay.width - resolvedWidth - edgeMargin)
        const belowY = useAnchorPosition
            ? anchorPoint.y
            : anchorPoint.y + anchorItem.height + verticalOffset
        const aboveY = anchorPoint.y - resolvedHeight - verticalOffset
        const maxY = Math.max(edgeMargin, overlay.height - resolvedHeight - edgeMargin)

        x = Math.max(edgeMargin, Math.min(maxX, anchorPoint.x))

        if (belowY <= maxY)
            y = Math.max(edgeMargin, belowY)
        else
            y = Math.max(edgeMargin, Math.min(maxY, aboveY))
    }

    function openAnchored() {
        useAnchorPosition = false
        reposition()
        open()
    }

    function openAt(anchor, point) {
        anchorItem = anchor
        anchorPosition = point
        useAnchorPosition = true
        reposition()
        open()
    }

    modal: false
    focus: true
    padding: 8
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay
    width: menuWidth

    onOpened: reposition()

    background: Rectangle {
        radius: 10
        color: "#1f1f1f"
        border.color: "#3a3a3a"
        border.width: 1
    }

    contentItem: ColumnLayout {
        id: contentColumn
        spacing: 4
    }
}
