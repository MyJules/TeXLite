import QtQuick
import QtQuick.Pdf
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

Rectangle {
    id: root
    radius: 4
    clip: true
    color: "lightgrey"

    function getTableView() {
        return view.children.length > 0 ? view.children[0] : null
    }

    function getCurrentLocation() {
        const tableView = getTableView()

        if (!tableView)
            return Qt.point(0, 0)

        const cell = tableView.cellAtPos(root.width / 2, root.height / 2)
        const currentItem = tableView.itemAtCell(cell)

        if (!currentItem)
            return Qt.point(0, 0)

        return Qt.point((tableView.contentX - currentItem.x + tableView.jumpLocationMargin.x) / renderScale,
                        (tableView.contentY - currentItem.y + tableView.jumpLocationMargin.y) / renderScale)
    }

    function openPage(pageNumber) {
        openLocation(pageNumber, Qt.point(0, 0), renderScale)
    }

    function scheduleViewerStyleRefresh() {
        styleRefreshAttempts = 20
        viewerStyleTimer.restart()
    }

    function applyViewerStyle() {
        const tableView = getTableView()

        if (!tableView)
            return

        tableView.rowSpacing = 6
        tableView.anchors.leftMargin = 0
    }

    function openLocation(pageNumber, location, zoom) {
        openPageNum = pageNumber
        openPageLocation = location
        openPageZoom = zoom
        scheduleViewerStyleRefresh()
        goToPageTimer.start()
    }

    function reset() {
        view.resetScale()
    }

    property int openPageNum: 0
    property point openPageLocation: Qt.point(0, 0)
    property real openPageZoom: 0
    property int styleRefreshAttempts: 0
    property alias source: doc.source
    property alias renderScale: view.renderScale
    property alias currentPage: view.currentPage

    Timer {
        id: goToPageTimer
        interval: 10
        running: true
        repeat: false
        onTriggered: {
            if (openPageNum < 0) {
                if (openPageZoom > 0)
                    renderScale = openPageZoom
                return
            }

            view.goToLocation(openPageNum,
                              openPageLocation,
                              openPageZoom > 0 ? openPageZoom : renderScale)
        }
    }

    Timer {
        id: viewerStyleTimer
        interval: 50
        running: false
        repeat: true
        onTriggered: {
            root.applyViewerStyle()

            root.styleRefreshAttempts -= 1
            if (root.styleRefreshAttempts <= 0)
                stop()
        }
    }

    PdfDocument {
        id: doc
    }

    PdfMultiPageView {
        id: view
        anchors.fill: parent
        document: doc
        renderScale: 1

        Component.onCompleted: root.scheduleViewerStyleRefresh()
        onDocumentChanged: root.scheduleViewerStyleRefresh()
    }

    Pane {
        id: controlsPanel
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 8
        anchors.leftMargin: 8
        padding: 6
        Material.elevation: 4

        background: Rectangle {
            radius: 8
            color: "#2b2b2b"
            border.width: 1
            border.color: "#4a4a4a"
        }

        ColumnLayout {
            spacing: 4

            RowLayout {
                spacing: 4

                ToolButton {
                    text: "+"
                    flat: true
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    font.pointSize: 12
                    font.bold: true

                    onClicked: view.renderScale *= Math.sqrt(2)
                }

                ToolButton {
                    text: "\u2212"
                    flat: true
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    font.pointSize: 12
                    font.bold: true

                    onClicked: view.renderScale /= Math.sqrt(2)
                }

                Label {
                    text: Math.round(view.renderScale * 100) + "%"
                    color: "#f0f0f0"
                    font.pointSize: 9
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Layout.minimumWidth: 46
                    Layout.preferredHeight: 28
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            RowLayout {
                spacing: 4
                Layout.alignment: Qt.AlignHCenter

                ToolButton {
                    text: "Width"
                    flat: true
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 26
                    font.pointSize: 9

                    onClicked: view.scaleToWidth(root.width, root.height)
                }

                ToolButton {
                    text: "Page"
                    flat: true
                    Layout.preferredWidth: 46
                    Layout.preferredHeight: 26
                    font.pointSize: 9

                    onClicked: view.scaleToPage(root.width, root.height)
                }
            }
        }
    }
}
