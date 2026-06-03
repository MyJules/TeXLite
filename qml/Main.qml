import QtQuick
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
    Material.roundedScale: Material.ExtraSmallScale

    property string currentFilePath
    property string compiledPDFPath
    property string projectCreationErrorText: ""
    property string saveErrorText: ""

    onClosing: clearPDFSource()

    menuBar: AppMenuBar {
        id: appMenuBar

        property bool saveDocumentClickedFlag: false

        saveDocumentButtonEnabled: editor.visible
        comileButtonEnabled: editor.visible
        saveButtonEnabled: editor.visible
        closeButtonEnabled: editor.visible

        onNewFileSelected: function (fileName) {
            root.onNewFileSelected(fileName)
        }

        onSaveFileClicked: {
            saveCurrentFile()
            if (root.saveErrorText) {
                saveErrorDialog.open()
                return
            }
            if (pdfLoader.visible)
                compile()
        }

        onCreateNewFileClicked: function (fileName) {
            fileSystem.newFile(fileName)
            projectView.visible = false
            editor.visible = true
        }

        onCompileClicked: {
            compile()
        }

        onSaveDocumentClicked: {
            if (!compiledPDFPath)
                return
            compileForce()
            appMenuBar.saveDocumentClickedFlag = true
        }

        FileDialog {
            id: saveDocumentDialog
            title: "Save PDF document"
            fileMode: FileDialog.SaveFile

            onAccepted: {
                fileSystem.copyFile(compiledPDFPath,
                                    saveDocumentDialog.selectedFile)
            }
        }

        onCloseFileClicked: {
            clearPDFSource()
            compiledPDFPath = ""
            currentFilePath = ""
            appFooter.foooterLineCountText = ""
            editor.visible = false
            projectView.visible = true
        }
    }

    footer: AppFooter {
        id: appFooter

        footerText: {
            if (currentFilePath) {
                var fileNameRegexp = /\/([^/]+)$/
                var match = fileNameRegexp.exec(currentFilePath)

                return match[1]
            } else {
                return "No file selected"
            }
        }

        showHideFilesEnabled: editor.visible
        showHidePDFEnabled: editor.visible

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
        }

        onDCompilationError: function (error) {
            pdfLoader.item.errorString = error
        }

        onDStateChanged: {
            switch (currentEngine.state) {
            case TexEngine.Idle:
                pdfLoader.sourceComponent = pdfViewComponent
                pdfLoader.item.source = compiledPDFPath
                if (pdfLoader.lastScrollPosition.x >= 0
                        && pdfLoader.lastScrollPosition.y >= 0) {
                    pdfLoader.item.restoreScrollPosition(pdfLoader.lastScrollPosition,
                                                         pdfLoader.lastRenderScale)
                } else {
                    pdfLoader.item.openLocation(pdfLoader.lastPage,
                                                pdfLoader.lastLocation,
                                                pdfLoader.lastRenderScale)
                }

                if (appMenuBar.saveDocumentClickedFlag) {
                    appMenuBar.saveDocumentClickedFlag = false
                    saveDocumentDialog.open()
                }

                break
            case TexEngine.Processing:
                if (pdfLoader.sourceComponent == pdfViewComponent) {
                    const currentViewState = pdfLoader.item.getCurrentViewState()

                    pdfLoader.lastRenderScale = pdfLoader.item.renderScale
                    pdfLoader.lastPage = currentViewState.page
                    pdfLoader.lastLocation = currentViewState.location
                    pdfLoader.lastScrollPosition = pdfLoader.item.getCurrentScrollPosition()
                }

                clearPDFSource()
                pdfLoader.sourceComponent = bisyPDFIndicatorComponent
                break
            case TexEngine.Error:
                clearPDFSource()
                pdfLoader.sourceComponent = compilationErrorViewComponent
                break
            default:
                break
            }
        }
    }

    ProjectView {
        id: projectView
        visible: true
        anchors.fill: parent

        onNewFileSelected: function (fileName) {
            root.onNewFileSelected(fileName)
        }

        onCreateExampleProjectRequested: function (exampleId, targetDir) {
            let fileName = fileSystem.createExampleProject(exampleId, targetDir)

            if (!fileName) {
                root.projectCreationErrorText = fileSystem.lastError
                        ? fileSystem.lastError
                        : "Failed to create the example project."
                projectCreationErrorDialog.open()
                return
            }

            root.onNewFileSelected(fileName)
        }
    }

    SplitView {
        id: editor
        visible: false
        clip: true
        anchors.fill: parent
        orientation: Qt.Horizontal

        DirView {
            id: dirView
            visible: false
            SplitView.minimumWidth: 150
            SplitView.preferredWidth: 250
            SplitView.maximumWidth: 250

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

            onDCursorPositionChanged: {
                appFooter.foooterLineCountText
                        = editor.visible ? ": " + (latexTextEdit.cursorLine + 1) : ""
            }
        }

        Loader {
            id: pdfLoader
            sourceComponent: pdfViewComponent
            visible: true

            property real lastRenderScale: 0
            property int lastPage: 0
            property point lastLocation: Qt.point(0, 0)
            property point lastScrollPosition: Qt.point(-1, -1)

            SplitView.preferredWidth: 600
            SplitView.minimumWidth: 200
        }

        Component {
            id: pdfViewComponent
            PDFView {}
        }
        Component {
            id: bisyPDFIndicatorComponent
            BusyPDFIndicator {}
        }

        Component {
            id: compilationErrorViewComponent
            CompilationErrorView {}
        }
    }

    FileSystem {
        id: fileSystem
    }

    MessageDialog {
        id: projectCreationErrorDialog
        title: "Example Project Error"
        text: root.projectCreationErrorText
        buttons: MessageDialog.Ok
    }

    MessageDialog {
        id: saveErrorDialog
        title: "Save File Error"
        text: root.saveErrorText
        buttons: MessageDialog.Ok
    }

    function compile() {
        if (!pdfLoader.visible)
            return
        fileSystem.clearTempFolder()
        saveCurrentFile()
        texEngines.currentEngine.compileToTempFolder(Date.now() + "")
    }

    function compileForce() {
        fileSystem.clearTempFolder()
        saveCurrentFile()
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

    function saveCurrentFile() {
        root.saveErrorText = ""

        if (!currentFilePath)
            return

        fileSystem.writeToFile(currentFilePath, latexTextEdit.text)
        if (fileSystem.lastError)
            root.saveErrorText = fileSystem.lastError
    }

    function clearPDFSource() {
        if (pdfLoader.source == "PDFView.qml") {
            pdfLoader.item.source = ""
        }
    }

    function onNewFileSelected(fileName) {
        setProcessingFile(fileName)
        loadFileWithDir(fileName)
        projectView.visible = false
        editor.visible = true
        compile()
    }
}
