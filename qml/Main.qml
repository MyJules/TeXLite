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
    property string compiledPDFPath

    menuBar: AppMenuBar {
        id: appMenuBar

        onNewEngineSelected: function (engineName) {
            texEngines.engineName = engineName
            compile()
        }

        onNewFileSelected: function (fileName) {
            currentFilePath = fileName
            texEngines.processingFile = fileName
            latexTextEdit.text = fileSystem.readFile(currentFilePath)
            compile()
        }

        onSaveFileClicked: {
            fileSystem.writeToFile(currentFilePath, latexTextEdit.text)
            compile()
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
            compile()
        }
    }

    footer: AppFooter {
        footerText: currentFilePath ? currentFilePath : "No file selected"
    }

    TexEngines {
        id: texEngines

        currentEngine.onCompilationFinished: function (filePath) {
            console.log("Compile: " + filePath)
            compiledPDFPath = "file:" + filePath
        }

        currentEngine.onCompilationStarted: {
            fileSystem.clearTempFolder()
        }

        currentEngine.onCompilationError: function (error) {
            console.log("Error: " + error)
        }

        currentEngine.onStateChanged: {
            console.log("State: " + texEngines.currentEngine.state)
            switch (texEngines.currentEngine.state) {
            case 0:
                console.log("PDF view")
                pdfLoader.source = "PDFView.qml"
                pdfLoader.item.source = compiledPDFPath

                break
            case 1:
                console.log("Busy")
                pdfLoader.source = "BusyPDFIndicator.qml"
                break
            default:
                break
            }
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

        Loader {
            id: pdfLoader
            source: "PDFView.qml"

            SplitView.preferredWidth: 600
            SplitView.minimumWidth: 200
        }
    }

    FileSystem {
        id: fileSystem
    }

    function compile() {
        texEngines.currentEngine.compileToTempFolder(Date.now() + "")
    }
}
