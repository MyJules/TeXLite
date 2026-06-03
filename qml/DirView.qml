import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Qt.labs.folderlistmodel

Item {
    id: root

    signal fileSelected(string filePath)
    signal dirSelected(string dirPath)
    signal pathDeleted(string deletedPath, bool folderEntry)

    property url directory: ""
    property string selectedPath: ""
    property var expandedFolders: ({})
    property var fileSystem: null
    property color panelColor: "#111111"
    property color surfaceColor: "#171717"
    property color borderColor: "#2b2b2b"
    property color textColor: "#ffffff"
    property color mutedTextColor: "#c4c4c4"
    property color hoverColor: "#2c2c2c"
    property color pressedColor: "#262626"
    property color selectedColor: "#f0f0f0"
    property color selectedTextColor: "#090909"
    property color hoverTextColor: "#ffffff"
    property string contextPath: ""
    property bool contextFolderEntry: false
    property string pendingDeletePath: ""
    property bool pendingDeleteFolderEntry: false
    property string pendingCreateFolderPath: ""
    property bool pendingCreateFolderEntry: false
    property string dirOperationErrorText: ""
    property var contextAnchorItem: null

    function normalizePath(path) {
        return path ? path.toString() : ""
    }

    function currentFolderName(path) {
        const normalized = normalizePath(path)

        if (!normalized)
            return "Files"

        const parts = normalized.split("/").filter(function(part) {
            return part !== "" && !part.endsWith(":") && part !== "file:"
        })

        if (parts.length >= 2)
            return parts[parts.length - 2] + "/" + parts[parts.length - 1]

        return parts.length > 0 ? parts[parts.length - 1] : normalized
    }

    function childPath(folderPath, name) {
        const basePath = normalizePath(folderPath)

        if (!basePath)
            return name

        return basePath.endsWith("/") ? basePath + name : basePath + "/" + name
    }

    function parentPath(path) {
        const normalized = normalizePath(path)
        const slashIndex = normalized.lastIndexOf("/")

        return slashIndex > "file:///".length ? normalized.substring(0, slashIndex) : normalized
    }

    function menuFolderPath(path, folderEntry) {
        return folderEntry ? normalizePath(path) : parentPath(path)
    }

    function openEntryContextMenu(path, folderEntry, anchorItem) {
        selectedPath = normalizePath(path)
        contextPath = normalizePath(path)
        contextFolderEntry = folderEntry
        contextAnchorItem = anchorItem
        entryContextMenu.anchorItem = anchorItem
        entryContextMenu.openAnchored()
    }

    function openDirectoryContextMenu(anchorItem, localPoint) {
        contextPath = normalizePath(directory)
        contextFolderEntry = true

        if (localPoint)
            directoryContextMenu.openAt(anchorItem, localPoint)
        else {
            directoryContextMenu.anchorItem = anchorItem
            directoryContextMenu.openAnchored()
        }
    }

    function beginCreate(folderPath, createFolder) {
        pendingCreateFolderPath = normalizePath(folderPath)
        pendingCreateFolderEntry = createFolder
        createNameField.text = ""
        createEntryDialog.title = createFolder ? "New Folder" : "New File"
        createEntryDialog.open()
    }

    function createPendingEntry() {
        const trimmedName = createNameField.text.trim()

        if (!trimmedName)
            return

        const createdPath = childPath(pendingCreateFolderPath, trimmedName)

        if (!fileSystem)
            return

        if (pendingCreateFolderEntry)
            fileSystem.newFolder(createdPath)
        else
            fileSystem.newFile(createdPath)

        if (fileSystem.lastError) {
            dirOperationErrorText = fileSystem.lastError
            dirOperationErrorDialog.open()
            return
        }

        setExpanded(pendingCreateFolderPath, true)
        selectedPath = createdPath

        if (pendingCreateFolderEntry)
            setExpanded(createdPath, true)
        else
            fileSelected(createdPath)
    }

    function beginDelete(path, folderEntry) {
        pendingDeletePath = normalizePath(path)
        pendingDeleteFolderEntry = folderEntry
        deleteEntryDialog.text = folderEntry
                                 ? "Delete this folder and all of its contents?"
                                 : "Delete this file?"
        deleteEntryDialog.open()
    }

    function deletePendingEntry() {
        if (!fileSystem || !pendingDeletePath)
            return

        const nextSelection = menuFolderPath(pendingDeletePath, pendingDeleteFolderEntry)

        fileSystem.removePath(pendingDeletePath)
        if (fileSystem.lastError) {
            dirOperationErrorText = fileSystem.lastError
            dirOperationErrorDialog.open()
            return
        }

        if (selectedPath === pendingDeletePath)
            selectedPath = nextSelection

        if (pendingDeleteFolderEntry)
            setExpanded(pendingDeletePath, false)

        pathDeleted(pendingDeletePath, pendingDeleteFolderEntry)
    }

    function isExpanded(path) {
        const normalized = normalizePath(path)
        return expandedFolders[normalized] === true
    }

    function setExpanded(path, expanded) {
        const normalized = normalizePath(path)
        const nextState = Object.assign({}, expandedFolders)

        if (expanded)
            nextState[normalized] = true
        else
            delete nextState[normalized]

        expandedFolders = nextState
    }

    onDirectoryChanged: {
        selectedPath = normalizePath(directory)
    }

    FolderListModel {
        id: navigationModel
        folder: root.directory
        showDirs: true
        showFiles: false
        showDotAndDotDot: false
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Rectangle {
            id: headerPanel
            Layout.fillWidth: true
            Layout.preferredHeight: 68
            radius: 10
            color: root.surfaceColor
            border.color: root.borderColor
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 10

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Label {
                        text: "FILES"
                        color: root.mutedTextColor
                        font.pointSize: 9
                        font.capitalization: Font.AllUppercase
                        font.letterSpacing: 1.2
                    }

                    Label {
                        Layout.fillWidth: true
                        elide: Text.ElideMiddle
                        text: root.currentFolderName(root.directory)
                        color: root.textColor
                        font.pointSize: 11
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                ToolButton {
                    visible: navigationModel.parentFolder && navigationModel.parentFolder !== root.directory
                    flat: true
                    text: "Up"
                    Material.roundedScale: Material.ExtraSmallScale
                    font.pointSize: 11
                    implicitWidth: 70
                    implicitHeight: 42

                    background: Rectangle {
                        radius: 8
                        color: parent.down ? root.pressedColor
                                           : parent.hovered ? root.hoverColor
                                                            : "transparent"
                        border.color: root.borderColor
                        border.width: 1
                    }

                    contentItem: Label {
                        text: parent.text
                        color: root.textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font: parent.font
                    }

                    onClicked: root.dirSelected(navigationModel.parentFolder)
                }
            }

            TapHandler {
                acceptedButtons: Qt.RightButton
                onTapped: function(eventPoint) {
                    root.openDirectoryContextMenu(headerPanel, eventPoint.position)
                }
            }
        }

        ScrollView {
            id: dirScrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            padding: 8

            TapHandler {
                acceptedButtons: Qt.RightButton
                onTapped: function(eventPoint) {
                    root.openDirectoryContextMenu(dirScrollView, eventPoint.position)
                }
            }

            background: Rectangle {
                radius: 10
                color: root.panelColor
                border.color: root.borderColor
                border.width: 1
            }

            contentWidth: availableWidth

            DirTreeNode {
                width: parent.width
                treeRoot: root
                folder: root.directory
                depth: 0
            }
        }
    }

    AppPopupMenu {
        id: entryContextMenu
        menuWidth: 220

        AppMenuItem {
            text: "New File"
            onClicked: {
                entryContextMenu.close()
                root.beginCreate(root.menuFolderPath(root.contextPath,
                                                     root.contextFolderEntry), false)
            }
        }

        AppMenuItem {
            text: "New Folder"
            onClicked: {
                entryContextMenu.close()
                root.beginCreate(root.menuFolderPath(root.contextPath,
                                                     root.contextFolderEntry), true)
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#343434"
        }

        AppMenuItem {
            text: root.contextFolderEntry ? "Delete Folder" : "Delete File"
            onClicked: {
                entryContextMenu.close()
                root.beginDelete(root.contextPath, root.contextFolderEntry)
            }
        }
    }

    AppPopupMenu {
        id: directoryContextMenu
        menuWidth: 220

        AppMenuItem {
            text: "New File"
            onClicked: {
                directoryContextMenu.close()
                root.beginCreate(root.normalizePath(root.directory), false)
            }
        }

        AppMenuItem {
            text: "New Folder"
            onClicked: {
                directoryContextMenu.close()
                root.beginCreate(root.normalizePath(root.directory), true)
            }
        }
    }

    Dialog {
        id: createEntryDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: 520
        padding: 0
        closePolicy: Popup.NoAutoClose
        standardButtons: Dialog.Ok | Dialog.Cancel
        Material.roundedScale: Material.ExtraSmallScale

        onAccepted: root.createPendingEntry()
        onOpened: createNameField.forceActiveFocus()

        background: Rectangle {
            radius: 12
            color: "#1d1d1d"
            border.color: "#3a3a3a"
            border.width: 1
        }

        header: Rectangle {
            implicitHeight: 52
            color: "#242424"
            radius: 12
            topLeftRadius: 12
            topRightRadius: 12
            bottomLeftRadius: 0
            bottomRightRadius: 0
            border.color: "#3a3a3a"
            border.width: 1

            Label {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                verticalAlignment: Text.AlignVCenter
                text: createEntryDialog.title
                color: "#f0f0f0"
                font.pointSize: 12
                font.bold: true
                elide: Text.ElideRight
            }
        }

        contentItem: ColumnLayout {
            width: 440
            spacing: 12

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                Layout.topMargin: 18
                text: root.pendingCreateFolderEntry
                      ? "Enter a folder name"
                      : "Enter a file name"
                color: "#d0d0d0"
                font.pointSize: 10.5
            }

            TextField {
                id: createNameField
                Layout.fillWidth: true
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                Layout.bottomMargin: 18
                implicitWidth: 420
                placeholderText: root.pendingCreateFolderEntry ? "folder" : "file.tex"
                selectByMouse: true

                background: Rectangle {
                    radius: 8
                    color: "#252525"
                    border.color: parent.activeFocus ? "#707070" : "#454545"
                    border.width: 1
                }

                color: "#f0f0f0"
                placeholderTextColor: "#7f7f7f"
                font.pointSize: 10.5
            }
        }

        footer: DialogButtonBox {
            standardButtons: createEntryDialog.standardButtons
            spacing: 10
            padding: 14
            alignment: Qt.AlignRight

            background: Rectangle {
                color: "#1d1d1d"
                border.color: "#3a3a3a"
                border.width: 1
                radius: 12
                topLeftRadius: 0
                topRightRadius: 0
                bottomLeftRadius: 12
                bottomRightRadius: 12
            }

            delegate: Button {
                flat: true
                Material.roundedScale: Material.ExtraSmallScale

                background: Rectangle {
                    radius: 8
                    color: down ? "#343434" : hovered ? "#2b2b2b" : "transparent"
                    border.color: "#4a4a4a"
                    border.width: 1
                }

                contentItem: Label {
                    text: parent.text
                    color: "#f0f0f0"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 10
                }
            }

            onAccepted: createEntryDialog.accept()
            onRejected: createEntryDialog.reject()
        }
    }

    AppMessageDialog {
        id: deleteEntryDialog
        title: "Delete"
        buttons: Dialog.Yes | Dialog.No

        onAccepted: {
            root.deletePendingEntry()
            root.pendingDeletePath = ""
        }

        onRejected: {
            root.pendingDeletePath = ""
        }
    }

    AppMessageDialog {
        id: dirOperationErrorDialog
        title: "Directory Operation Error"
        text: root.dirOperationErrorText
        buttons: Dialog.Ok
    }
}
