import QtQuick
import QtQuick.Pdf
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Universal

Rectangle {
    id: root
    radius: 4
    clip: true
    color: "lightgrey"

    function openPage(pageNumber) {
        openPageNum = pageNumber
        goToPageTimer.start()
    }

    function reset() {
        view.resetScale()
    }

    property int openPageNum: 0
    property alias source: doc.source
    property alias scale: view.renderScale
    property alias currentPage: view.currentPage

    Timer {
        id: goToPageTimer
        interval: 10
        running: true
        repeat: false
        onTriggered: view.goToLocation(openPageNum, Qt.point(0, 0), scale)
    }

    PdfDocument {
        id: doc
    }

    PdfMultiPageView {
        id: view
        anchors.fill: parent
        document: doc
        renderScale: 1
    }

    Rectangle {
        color: "#7a7a7a77"
        implicitWidth: row.implicitWidth
        implicitHeight: row.implicitHeight
        radius: 4
        visible: true

        RowLayout {
            id: row
            spacing: 10
            anchors.topMargin: 10

            ToolButton {
                text: " + "
                height: 18
                flat: true
                font.pointSize: 14

                onClicked: {
                    view.renderScale *= Math.sqrt(2)
                }
            }
            ToolButton {
                text: " - "
                height: 18
                flat: true
                font.pointSize: 14

                onClicked: {
                    view.renderScale /= Math.sqrt(2)
                }
            }
            ToolButton {
                text: " <-> "
                height: 18
                flat: true
                font.pointSize: 14

                onClicked: {
                    view.scaleToWidth(root.width, root.height)
                }
            }

            ToolButton {
                text: " |-| "
                height: 18
                flat: true
                font.pointSize: 14

                onClicked: {
                    view.scaleToPage(root.width, root.height)
                }
            }
        }
    }
}
