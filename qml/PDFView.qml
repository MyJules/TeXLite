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

    RowLayout {
        spacing: 10
        anchors.topMargin: 10

        Item {}

        Button {
            text: "+"
            height: 28
            flat: true
            font.pointSize: 16

            onClicked: {
                view.renderScale *= Math.sqrt(2)
            }
        }
        Button {
            text: "-"
            height: 28
            flat: true
            font.pointSize: 16

            onClicked: {
                view.renderScale /= Math.sqrt(2)
            }
        }
        Button {
            text: "<->"
            height: 28
            flat: true
            font.pointSize: 16

            onClicked: {
                view.scaleToWidth(root.width, root.height)
            }
        }
    }
}
