import QtQuick
import QtQuick.Pdf
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    radius: 4
    clip: true
    color: "lightgrey"

    property alias source: doc.source

    PdfDocument {
        id: doc
    }

    PdfMultiPageView {
        id: view
        anchors.fill: parent
        document: doc
    }

    Rectangle {
        color: "gray"
        implicitWidth: row.implicitWidth
        implicitHeight: row.implicitHeight

        RowLayout {
            id: row
            spacing: 10
            anchors.topMargin: 10

            ToolButton {
                text: " + "
                height: 24
                flat: true
                font.pointSize: 14

                onClicked: {
                    view.renderScale *= Math.sqrt(2)
                }
            }
            ToolButton {
                text: " - "
                height: 24
                flat: true
                font.pointSize: 14

                onClicked: {
                    view.renderScale /= Math.sqrt(2)
                }
            }
            ToolButton {
                text: " <-> "
                height: 24
                flat: true
                font.pointSize: 14

                onClicked: {
                    view.scaleToWidth(root.width, root.height)
                }
            }

            ToolButton {
                text: " |-| "
                height: 24
                flat: true
                font.pointSize: 14

                onClicked: {
                    view.scaleToPage(root.width, root.height)
                }
            }
        }
    }
}
