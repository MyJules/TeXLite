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
    property string mainFilePath: ""
    property string compiledPDFPath
    property string projectCreationErrorText: ""
    property string compilationErrorText: ""
    property string saveErrorText: ""
    property string loadedFileText: ""
    property bool suppressEditorDirtyTracking: false
    property bool editorDirty: false
    property string pendingExternalFilePath: ""

    onClosing: clearPDFSource()

    function fileNameFromPath(filePath) {
        if (!filePath)
            return ""

        const fileNameRegexp = /\/([^/]+)$/
        const match = fileNameRegexp.exec(filePath)

        return match ? match[1] : filePath
    }

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
            if (appMenuBar.compileOnSaveEnabled)
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
            mainFilePath = ""
            loadedFileText = ""
            editorDirty = false
            fileSystem.watchFile("")
            appFooter.foooterLineCountText = ""
            editor.visible = false
            projectView.visible = true
        }
    }

    footer: AppFooter {
        id: appFooter

        footerText: {
            if (!currentFilePath)
                return "No file selected"

            const currentFileName = root.fileNameFromPath(currentFilePath)
            const mainFileName = root.fileNameFromPath(mainFilePath)
            const displayedCurrentFileName = root.editorDirty
                    ? "*" + currentFileName
                    : currentFileName

            if (!mainFileName || currentFilePath === mainFilePath)
                return displayedCurrentFileName

            return mainFileName + " -> " + displayedCurrentFileName
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
            root.compilationErrorText = ""
            compiledPDFPath = "file:" + filePath
        }

        onDCompilationStarted: {
        }

        onDCompilationError: function (error) {
            root.compilationErrorText = error

            if (pdfLoader.visible && pdfLoader.item)
                pdfLoader.item.errorString = error
            else
                compilationErrorDialog.open()
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
                if (pdfLoader.visible) {
                    clearPDFSource()
                    pdfLoader.sourceComponent = compilationErrorViewComponent
                    if (pdfLoader.item)
                        pdfLoader.item.errorString = root.compilationErrorText
                }
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
            fileSystem: fileSystem
            SplitView.minimumWidth: 150
            SplitView.preferredWidth: 250
            SplitView.maximumWidth: 250

            onFileSelected: function (filePath) {
                loadFileWithDir(filePath)
            }

            onDirSelected: function (dirPath) {
                dirView.directory = dirPath
            }

            onPathDeleted: function (deletedPath, folderEntry) {
                const deletedPrefix = deletedPath.endsWith("/")
                        ? deletedPath
                        : deletedPath + "/"
                const removedCurrentFile = root.currentFilePath
                        && (root.currentFilePath === deletedPath
                            || (folderEntry && root.currentFilePath.startsWith(deletedPrefix)))
                const removedMainFile = root.mainFilePath
                        && (root.mainFilePath === deletedPath
                            || (folderEntry && root.mainFilePath.startsWith(deletedPrefix)))

                if (!removedCurrentFile && !removedMainFile)
                    return

                clearPDFSource()
                compiledPDFPath = ""

                if (removedCurrentFile) {
                    currentFilePath = ""
                    loadedFileText = ""
                    editorDirty = false
                    latexTextEdit.text = ""
                    fileSystem.watchFile("")
                    appFooter.foooterLineCountText = ""
                }

                if (removedMainFile) {
                    mainFilePath = ""
                    texEngines.processingFile = ""
                }

                if (!currentFilePath) {
                    editor.visible = false
                    projectView.visible = true
                }
            }
        }

        LatexTextEditWithIntellisense {
            id: latexTextEdit
            SplitView.fillWidth: true
            SplitView.minimumWidth: 150
            SplitView.preferredWidth: 200

            onTextChanged: {
                if (root.suppressEditorDirtyTracking)
                    return

                root.editorDirty = latexTextEdit.text !== root.loadedFileText
            }

            onDCursorPositionChanged: {
                appFooter.foooterLineCountText
                        = editor.visible ? " : " + (latexTextEdit.cursorLine + 1) : ""
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
            PDFView {
                onSourceJumpRequested: function (page, location) {
                    texEngines.currentEngine.syncTeXToSource(root.compiledPDFPath,
                                                             page,
                                                             location.x,
                                                             location.y)
                }
            }
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

    AppMessageDialog {
        id: projectCreationErrorDialog
        title: "Example Project Error"
        text: root.projectCreationErrorText
        buttons: Dialog.Ok
    }

    AppMessageDialog {
        id: saveErrorDialog
        title: "Save File Error"
        text: root.saveErrorText
        buttons: Dialog.Ok
    }

    AppMessageDialog {
        id: compilationErrorDialog
        title: "Compilation Error"
        text: root.compilationErrorText
        buttons: Dialog.Ok
    }

    AppMessageDialog {
        id: externalFileChangedDialog
        title: "File Changed"
        text: "The current file changed outside TeXLite. Reload and discard local edits?"
        buttons: Dialog.Yes | Dialog.No

        onAccepted: {
            if (root.pendingExternalFilePath) {
                root.loadFileWithDir(root.pendingExternalFilePath)
            }
            root.pendingExternalFilePath = ""
        }

        onRejected: {
            root.pendingExternalFilePath = ""
        }
    }

    function compile() {
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
        root.mainFilePath = fileName
        texEngines.processingFile = fileName
    }

    function loadFileWithDir(fileName) {
        root.suppressEditorDirtyTracking = true
        latexTextEdit.text = fileSystem.readFile(fileName)
        root.loadedFileText = latexTextEdit.text
        root.editorDirty = false
        root.suppressEditorDirtyTracking = false
        dirView.directory = fileSystem.getFileDir(fileName)
        dirView.selectedPath = fileName
        currentFilePath = fileName
        fileSystem.watchFile(fileName)
    }

    function saveCurrentFile() {
        root.saveErrorText = ""

        if (!currentFilePath)
            return

        fileSystem.writeToFile(currentFilePath, latexTextEdit.text)
        if (fileSystem.lastError)
            root.saveErrorText = fileSystem.lastError
        else {
            root.loadedFileText = latexTextEdit.text
            root.editorDirty = false
        }
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

    function openIncludedSourceIfPresent(baseFilePath, lineNumber) {
        if (!baseFilePath)
            return false

        const lines = latexTextEdit.text.split("\n")
        const lineIndex = Math.max(0, Math.min(lines.length - 1, lineNumber - 1))
        const lineText = lines.length > 0 ? lines[lineIndex] : ""
        const match = /\\(?:input|include)\s*\{\s*([^}]+)\s*\}/.exec(lineText)

        if (!match)
            return false

        const includePath = fileSystem.resolveRelativeFilePath(baseFilePath, match[1])

        if (!includePath)
            return false

        root.loadFileWithDir(includePath)
        latexTextEdit.moveCursorTo(1, 1)
        return true
    }

    Connections {
        target: fileSystem

        function onWatchedFileChanged(filePath) {
            if (!root.currentFilePath || filePath !== root.currentFilePath)
                return

            if (!root.editorDirty) {
                root.loadFileWithDir(filePath)
                return
            }

            root.pendingExternalFilePath = filePath
            externalFileChangedDialog.open()
        }
    }

    Connections {
        target: texEngines

        function onDReverseSearchResolved(filePath, line, column) {
            const resolvedPath = fileSystem.normalizeFilePath(filePath)
            const currentPath = fileSystem.normalizeFilePath(root.currentFilePath)

            if (!resolvedPath)
                return

            if (currentPath !== resolvedPath)
                root.loadFileWithDir(filePath)

            latexTextEdit.moveCursorTo(line, column)

            openIncludedSourceIfPresent(resolvedPath, line)
        }
    }
}
