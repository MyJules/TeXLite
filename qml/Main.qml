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
            loadFile(fileName)
            pdfLoader.visible = true
            dirView.visible = true
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
                fileSystem.newFile(newFileDialog.currentFile)
                loadFile(newFileDialog.currentFile)
                pdfLoader.visible = true
                dirView.visible = true
            }
        }

        onCompileClicked: {
            compile()
        }
    }

    footer: AppFooter {
        footerText: currentFilePath ? currentFilePath : "No file selected"

        onShowHidePDFClicked: {
            pdfLoader.visible = !pdfLoader.visible
            if (pdfLoader.visible)
                compile()
        }

        onShowHideFileViewCliced: {
            dirView.visible = !dirView.visible
        }
    }

    TexEngines {
        id: texEngines

        onDCompilationFinished: function (filePath) {
            compiledPDFPath = "file:" + filePath
        }

        onDCompilationStarted: {
            fileSystem.clearTempFolder()
        }

        onDCompilationError: function (error) {}

        onDStateChanged: {
            switch (currentEngine.state) {
            case TexEngine.Idle:
                pdfLoader.source = "PDFView.qml"
                pdfLoader.item.source = compiledPDFPath
                pdfLoader.item.renderScale = pdfLoader.lastRenderScale
                break
            case TexEngine.Processing:
                pdfLoader.lastRenderScale = pdfLoader.item.renderScale
                pdfLoader.lastPage = pdfLoader.item.currentPage
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

        DirView {
            id: dirView
            visible: false
            SplitView.minimumWidth: 100
            SplitView.preferredWidth: 150
            SplitView.maximumWidth: 300

            onFileSelected: function (filePath) {
                console.log(filePath)
            }
            onDirSelected: function (dirPath) {
                console.log(dirPath)
            }
        }

        LatexTextEdit {
            id: latexTextEdit
            SplitView.fillWidth: true
            SplitView.minimumWidth: 300
            SplitView.preferredWidth: 400
        }

        Loader {
            id: pdfLoader
            source: "PDFView.qml"
            visible: false

            property real lastRenderScale: 0
            property int lastPage: 0

            SplitView.preferredWidth: 600
            SplitView.minimumWidth: 200
        }
    }

    FileSystem {
        id: fileSystem
    }

    function compile() {
        if (!pdfLoader.visible)
            return
        texEngines.currentEngine.compileToTempFolder(Date.now() + "")
    }

    function loadFile(fileName) {
        texEngines.processingFile = fileName
        latexTextEdit.text = fileSystem.readFile(fileName)
        dirView.directory = fileSystem.getFileDir(fileName)
        currentFilePath = fileName
    }
}
