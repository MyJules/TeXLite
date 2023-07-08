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

    onClosing: clearPDFSource()

    menuBar: AppMenuBar {
        id: appMenuBar

        onNewEngineSelected: function (engineName) {
            texEngines.engineName = engineName
            compile()
        }

        onNewFileSelected: function (fileName) {
            setProcessingFile(fileName)
            loadFileWithDir(fileName)
            pdfLoader.visible = true
            dirView.visible = true
            compile()
        }

        onSaveFileClicked: {
            fileSystem.writeToFile(currentFilePath, latexTextEdit.text)
            compile()
        }

        onCreateNewFileClicked: function (fileName) {
            fileSystem.newFile(fileName)
            setProcessingFile(fileName)
            loadFileWithDir(fileName)
            pdfLoader.visible = true
            dirView.visible = true
        }

        onCompileClicked: {
            compile()
        }

        onSaveDocumentClicked: function (filePath) {
            if (!filePath || !compiledPDFPath)
                return

            console.log(compiledPDFPath)
            console.log(filePath)
            fileSystem.copyFile(compiledPDFPath, filePath)
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

        onDCompilationError: function (error) {
            pdfLoader.item.errorString = error
        }

        onDStateChanged: {
            switch (currentEngine.state) {
            case TexEngine.Idle:
                pdfLoader.source = "PDFView.qml"
                pdfLoader.item.source = compiledPDFPath
                pdfLoader.item.renderScale = pdfLoader.lastRenderScale
                pdfLoader.item.openPage(pdfLoader.lastPage)
                break
            case TexEngine.Processing:
                if (pdfLoader.source == "PDFView.qml") {
                    pdfLoader.lastRenderScale = pdfLoader.item.renderScale
                    pdfLoader.lastPage = pdfLoader.item.currentPage
                }

                clearPDFSource()
                pdfLoader.source = "BusyPDFIndicator.qml"
                break
            case TexEngine.Error:
                clearPDFSource()
                pdfLoader.source = "CompilationErrorView.qml"
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
            SplitView.preferredWidth: 120
            SplitView.maximumWidth: 300

            onFileSelected: function (filePath) {
                loadFileWithDir(filePath)
            }

            onDirSelected: function (dirPath) {
                dirView.directory = dirPath
            }
        }

        LatexTextEditWithIntellisense {
            id: latexTextEdit
            SplitView.fillWidth: true
            SplitView.minimumWidth: 150
            SplitView.preferredWidth: 200
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

    function setProcessingFile(fileName) {
        texEngines.processingFile = fileName
    }

    function loadFileWithDir(fileName) {
        latexTextEdit.text = fileSystem.readFile(fileName)
        dirView.directory = fileSystem.getFileDir(fileName)
        currentFilePath = fileName
    }

    function clearPDFSource() {
        if (pdfLoader.source == "PDFView.qml") {
            pdfLoader.item.source = ""
        }
    }
}
