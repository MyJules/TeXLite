import QtQuick
import QtQuick.Pdf

Rectangle {
    id: latexPDF
    clip: true
    color: "lightgrey"
    radius: 4

    PdfDocument {
        id: doc
        source: "qrc:/test/pdf/resource/Test.pdf"
    }

    PdfMultiPageView {
        id: view
        anchors.fill: parent
        document: doc
    }
}
