import QtQuick
import QtQuick.Pdf
import QtQuick.Dialogs
import QtQuick.Controls 2.15
import QtQuick.Controls.Material

import com.tex
import com.file

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
            texEngines.processingFile = fileName
            latexTextEdit.text = fileSystem.readFile(currentFilePath)
        }

        onSaveFileClicked: {
            fileSystem.writeToFile(currentFilePath, latexTextEdit.text)
        }

        onCreateNewFileClicked: {
            newFileDialog.open()
        }

        FileDialog {
            id: newFileDialog
            title: "New File"
            fileMode: FileDialog.SaveFile

            onAccepted: {
                fileSystem.newFile("file:" + newFileDialog.currentFile)
            }
        }

        onCompileClicked: {
            texEngines.currentEngine.compileToTempFolder(Date.now() + ".pdf")
        }
    }

    footer: AppFooter {
        footerText: currentFilePath ? currentFilePath : "No file selected"
    }

    TexEngines {
        id: texEngines
        currentEngine.onCompilationFinished: function (compiledFilePath) {
            pdfView.source = "file:" + compiledFilePath
            fileSystem.clearTempFolder()
        }
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

    FileSystem {
        id: fileSystem
    }
}
