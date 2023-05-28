import QtQuick
import QtQuick.Pdf

Rectangle {
    id: latexPDF
    clip: true
    color: "lightgrey"
    radius: 4

    PdfDocument {
        id: doc
        source: "file:temp.pdf"
    }

    PdfMultiPageView {
        id: view
        anchors.fill: parent
        document: doc
    }
}
