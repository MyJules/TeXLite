import QtQuick
import QtQuick.Pdf
import QtQuick.Controls.Material

Rectangle {
    id: latexPDF
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
