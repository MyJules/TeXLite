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

    signal sourceJumpRequested(int page, point location)

    function getTableView() {
        return view.children.length > 0 ? view.children[0] : null
    }

    function getLocationForCell(tableView, cell, positionX, positionY) {
        if (cell.x < 0 || cell.y < 0)
            return null

        const currentItem = tableView.itemAtCell(cell)

        if (!currentItem)
            return null

        const localX = Math.max(0, tableView.contentX + positionX - currentItem.x)
        const localY = Math.max(0, tableView.contentY + positionY - currentItem.y)

        return {
            page: cell.y,
            location: Qt.point((localX
                                + tableView.jumpLocationMargin.x) / renderScale,
                               (localY
                                + tableView.jumpLocationMargin.y) / renderScale)
        }
    }

    function getViewStateAt(positionX, positionY) {
        const tableView = getTableView()

        if (!tableView)
            return null

        const clampedX = Math.max(0, Math.min(root.width - 1, positionX))
        const clampedY = Math.max(0, Math.min(root.height - 1, positionY))
        const cell = tableView.cellAtPosition(clampedX, clampedY, true)

        return getLocationForCell(tableView, cell, clampedX, clampedY)
    }

    function getCurrentViewState() {
        const sampleXs = [root.width / 2, root.width * 0.25, root.width * 0.75]
        const sampleYs = [root.height / 2, 1, root.height * 0.25, root.height * 0.75,
                          root.height - 1]

        for (let yIndex = 0; yIndex < sampleYs.length; ++yIndex) {
            for (let xIndex = 0; xIndex < sampleXs.length; ++xIndex) {
                const state = getViewStateAt(sampleXs[xIndex], sampleYs[yIndex])

                if (state)
                    return state
            }
        }

        return {
            page: currentPage >= 0 ? currentPage : 0,
            location: Qt.point(0, 0)
        }
    }

    function getCurrentLocation() {
        return getCurrentViewState().location
    }

    function getCurrentScrollPosition() {
        const tableView = getTableView()

        if (!tableView)
            return Qt.point(0, 0)

        return Qt.point(tableView.contentX, tableView.contentY)
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

        viewerTableView = tableView
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

    function restoreScrollPosition(position, zoom) {
        openScrollPosition = position
        openPageZoom = zoom
        scrollRestoreAttempts = 20
        scrollRestoreTimer.restart()
    }

    function reset() {
        view.resetScale()
    }

    function zoomByFactor(factor) {
        const scrollPosition = getCurrentScrollPosition()
        const nextZoom = renderScale * factor

        restoreScrollPosition(Qt.point(scrollPosition.x * factor,
                                       scrollPosition.y * factor),
                              nextZoom)
    }

    function setVerticalScrollFromThumb(thumbY, thumbHeight, trackHeight) {
        if (!viewerTableView)
            return

        const available = Math.max(1, trackHeight - thumbHeight - 4)
        const ratio = Math.max(0, Math.min(1, (thumbY - 2) / available))
        const maxScroll = Math.max(0, viewerTableView.contentHeight - viewerTableView.height)

        viewerTableView.contentY = ratio * maxScroll
    }

    function setHorizontalScrollFromThumb(thumbX, thumbWidth, trackWidth) {
        if (!viewerTableView)
            return

        const available = Math.max(1, trackWidth - thumbWidth - 4)
        const ratio = Math.max(0, Math.min(1, (thumbX - 2) / available))
        const maxScroll = Math.max(0, viewerTableView.contentWidth - viewerTableView.width)

        viewerTableView.contentX = ratio * maxScroll
    }

    property int openPageNum: 0
    property point openPageLocation: Qt.point(0, 0)
    property real openPageZoom: 0
    property point openScrollPosition: Qt.point(-1, -1)
    property int scrollRestoreAttempts: 0
    property int styleRefreshAttempts: 0
    property var viewerTableView: null
    property bool verticalThumbDragging: false
    property real verticalThumbDragY: 2
    property real verticalThumbPressOffset: 0
    property bool horizontalThumbDragging: false
    property real horizontalThumbDragX: 2
    property real horizontalThumbPressOffset: 0
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

    Timer {
        id: scrollRestoreTimer
        interval: 50
        running: false
        repeat: true
        onTriggered: {
            const tableView = getTableView()

            if (!tableView)
                return

            if (openPageZoom > 0)
                renderScale = openPageZoom

            const targetX = Math.max(0, Math.min(openScrollPosition.x,
                                                 Math.max(0,
                                                          tableView.contentWidth
                                                          - tableView.width)))
            const targetY = Math.max(0, Math.min(openScrollPosition.y,
                                                 Math.max(0,
                                                          tableView.contentHeight
                                                          - tableView.height)))

            tableView.contentX = targetX
            tableView.contentY = targetY

            scrollRestoreAttempts -= 1
            if (scrollRestoreAttempts <= 0
                    || (Math.abs(tableView.contentX - targetX) < 0.5
                        && Math.abs(tableView.contentY - targetY) < 0.5)) {
                stop()
            }
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

    MouseArea {
        anchors.fill: view
        acceptedButtons: Qt.LeftButton
        hoverEnabled: false

        onDoubleClicked: function(mouse) {
            const state = root.getViewStateAt(mouse.x, mouse.y)

            if (state){
                root.sourceJumpRequested(state.page, state.location)
            }
        }
    }

    Item {
        anchors.fill: parent
        z: 2

        Rectangle {
            id: verticalScrollTrack
            visible: root.viewerTableView
                     && root.viewerTableView.contentHeight > root.viewerTableView.height + 1
            width: 10
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.topMargin: 12
            anchors.bottomMargin: 12
            anchors.rightMargin: 6
            radius: 5
            color: "#15151588"

            Rectangle {
                id: verticalThumb
                width: 6
                x: 2
                radius: 3
                color: "#5f6368"
                y: {
                    if (root.verticalThumbDragging)
                        return root.verticalThumbDragY

                    if (!root.viewerTableView)
                        return 2

                    const maxScroll = Math.max(1, root.viewerTableView.contentHeight - root.viewerTableView.height)
                    const available = parent.height - height - 4
                    return 2 + (root.viewerTableView.contentY / maxScroll) * Math.max(0, available)
                }
                height: {
                    if (!root.viewerTableView)
                        return 40

                    const ratio = root.viewerTableView.height / root.viewerTableView.contentHeight
                    return Math.max(44, (parent.height - 4) * Math.min(1, ratio))
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    preventStealing: true

                    onPressed: function(mouse) {
                        root.verticalThumbDragging = true
                        root.verticalThumbPressOffset = mouse.y
                        root.verticalThumbDragY = Math.max(2,
                                                           Math.min(verticalScrollTrack.height - parent.height - 2,
                                                                    parent.y))
                        root.setVerticalScrollFromThumb(root.verticalThumbDragY,
                                                        parent.height,
                                                        verticalScrollTrack.height)
                    }

                    onPositionChanged: function(mouse) {
                        if (!(mouse.buttons & Qt.LeftButton))
                            return

                        root.verticalThumbDragY = Math.max(2,
                                                           Math.min(verticalScrollTrack.height - parent.height - 2,
                                                                    verticalScrollTrack.mapFromItem(parent, mouse.x, mouse.y).y
                                                                    - root.verticalThumbPressOffset))
                        root.setVerticalScrollFromThumb(root.verticalThumbDragY,
                                                        parent.height,
                                                        verticalScrollTrack.height)
                    }

                    onReleased: root.verticalThumbDragging = false
                    onCanceled: root.verticalThumbDragging = false
                }
            }
        }

        Rectangle {
            id: horizontalScrollTrack
            visible: root.viewerTableView
                     && root.viewerTableView.contentWidth > root.viewerTableView.width + 1
            height: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 12
            anchors.rightMargin: 24
            anchors.bottomMargin: 6
            radius: 5
            color: "#15151588"

            Rectangle {
                id: horizontalThumb
                height: 6
                y: 2
                radius: 3
                color: "#5f6368"
                x: {
                    if (root.horizontalThumbDragging)
                        return root.horizontalThumbDragX

                    if (!root.viewerTableView)
                        return 2

                    const maxScroll = Math.max(1, root.viewerTableView.contentWidth - root.viewerTableView.width)
                    const available = parent.width - width - 4
                    return 2 + (root.viewerTableView.contentX / maxScroll) * Math.max(0, available)
                }
                width: {
                    if (!root.viewerTableView)
                        return 40

                    const ratio = root.viewerTableView.width / root.viewerTableView.contentWidth
                    return Math.max(44, (parent.width - 4) * Math.min(1, ratio))
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    preventStealing: true

                    onPressed: function(mouse) {
                        root.horizontalThumbDragging = true
                        root.horizontalThumbPressOffset = mouse.x
                        root.horizontalThumbDragX = Math.max(2,
                                                             Math.min(horizontalScrollTrack.width - parent.width - 2,
                                                                      parent.x))
                        root.setHorizontalScrollFromThumb(root.horizontalThumbDragX,
                                                          parent.width,
                                                          horizontalScrollTrack.width)
                    }

                    onPositionChanged: function(mouse) {
                        if (!(mouse.buttons & Qt.LeftButton))
                            return

                        root.horizontalThumbDragX = Math.max(2,
                                                             Math.min(horizontalScrollTrack.width - parent.width - 2,
                                                                      horizontalScrollTrack.mapFromItem(parent, mouse.x, mouse.y).x
                                                                      - root.horizontalThumbPressOffset))
                        root.setHorizontalScrollFromThumb(root.horizontalThumbDragX,
                                                          parent.width,
                                                          horizontalScrollTrack.width)
                    }

                    onReleased: root.horizontalThumbDragging = false
                    onCanceled: root.horizontalThumbDragging = false
                }
            }
        }
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

                    onClicked: root.zoomByFactor(Math.sqrt(2))
                }

                ToolButton {
                    text: "\u2212"
                    flat: true
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    font.pointSize: 12
                    font.bold: true

                    onClicked: root.zoomByFactor(1 / Math.sqrt(2))
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
