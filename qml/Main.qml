import QtQuick
import QtQuick.Pdf
import QtQuick.Controls 2.15
import QtQuick.Controls.Material
import com.tex

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

    property string currentFilePath

    menuBar: AppMenuBar {
        id: appMenuBar
        onNewEngineSelected: function (engineName) {
            texEngines.engineName = engineName
        }
        onNewFileSelected: function (fileName) {
            currentFilePath = fileName
            latexTextEdit.currentFilePath = fileName
            texEngines.processingFile = fileName
        }
    }

    footer: AppFooter {}

    TexEngines {
        id: texEngines
    }

    SplitView {
        id: rowLayout
        clip: true
        anchors.fill: parent
        orientation: Qt.Horizontal

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
