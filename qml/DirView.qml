import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Qt.labs.folderlistmodel

Item {
    id: root

    signal fileSelected(string filePath)
    signal dirSelected(string dirPath)

    property url directory: ""
    property string selectedPath: ""
    property var expandedFolders: ({})
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

    function normalizePath(path) {
        return path ? path.toString() : ""
    }

    function childPath(folderPath, name) {
        const basePath = normalizePath(folderPath)

        if (!basePath)
            return name

        return basePath.endsWith("/") ? basePath + name : basePath + "/" + name
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
                        text: root.normalizePath(root.directory)
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
                    font.pointSize: 10

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
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            padding: 8

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
}
