import QtQuick
import QtQuick.Pdf
import QtQuick.Controls 2.15
import QtQuick.Controls.Material

ApplicationWindow {
    id: root
    visible: true

    title: "TeXLite"

    width: 1280
    height: 720

    minimumWidth: 800
    minimumHeight: 400

    Material.theme: Material.Dark
    Material.accent: Material.Grey
    Material.roundedScale: Material.NotRounded

    menuBar: AppMenuBar {
        id: appMenuBar
        onCurrentFileChanged: {

        }
    }
    footer: AppFooter {}

    SplitView {
        id: rowLayout
        clip: true
        anchors.fill: parent
        orientation: Qt.Horizontal

        //        FileSystem{
        //            SplitView.preferredWidth: 150
        //            SplitView.minimumWidth: 100
        //        }
        LatexTextEdit {
            id: latexTextEdit
            SplitView.fillWidth: true
            SplitView.preferredWidth: 400
            SplitView.minimumWidth: 300
        }

        PDFView {
            id: pdfView
            SplitView.preferredWidth: 600
            SplitView.minimumWidth: 200
        }
    }
}
