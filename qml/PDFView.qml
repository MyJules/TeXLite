import QtQuick
import QtQuick.Pdf

Rectangle {
    id: latexPDF
    radius: 4
    clip: true
    color: "lightgrey"

    property alias source: doc.source

    PdfDocument {
        id: doc
        source: Qt.resolvedUrl("file:temp.pdf")
    }

    PdfMultiPageView {
        id: view
        anchors.fill: parent
        document: doc
    }
}
