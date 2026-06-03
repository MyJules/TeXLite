import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Qt.labs.folderlistmodel

Item {
    id: node

    property var treeRoot: null
    property url folder: ""
    property int depth: 0
    property int rowHeight: 34
    property int branchSpacing: 4

    implicitWidth: parent ? parent.width : 0
    implicitHeight: contentColumn.implicitHeight

    FolderListModel {
        id: folderModel
        folder: node.folder
        showDirs: true
        showFiles: true
        showDirsFirst: true
        showDotAndDotDot: false
        sortField: FolderListModel.Name
    }

    Column {
        id: contentColumn
        width: parent ? parent.width : 0
        spacing: node.branchSpacing

        Repeater {
            model: folderModel

            delegate: Item {
                id: entryItem

                readonly property bool folderEntry: folderModel.isFolder(index)
                readonly property string entryPath: node.treeRoot.childPath(node.folder, fileName)
                readonly property bool branchVisible: folderEntry
                                                     && childLoader.active
                                                     && childLoader.item
                readonly property real branchHeight: branchVisible
                                                   ? childLoader.item.implicitHeight
                                                   : 0

                width: node.width
                implicitHeight: node.rowHeight
                                + (branchVisible ? node.branchSpacing + branchHeight : 0)

                Column {
                    id: entryColumn
                    width: parent.width
                    spacing: node.branchSpacing
                    height: entryItem.implicitHeight

                    Rectangle {
                        width: parent.width
                        height: node.rowHeight
                        radius: 8
                        color: mouseArea.pressed
                               ? node.treeRoot.pressedColor
                                                             : node.treeRoot.selectedPath === entryItem.entryPath
                                                                 ? node.treeRoot.selectedColor
                                                                 : mouseArea.containsMouse
                                                                     ? node.treeRoot.hoverColor
                                   : entryItem.folderEntry
                                     ? node.treeRoot.surfaceColor
                                     : "transparent"
                        border.color: node.treeRoot.selectedPath === entryItem.entryPath
                                      ? node.treeRoot.selectedColor
                                                                            : (mouseArea.containsMouse ? node.treeRoot.mutedTextColor : "transparent")
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10 + node.depth * 16
                            anchors.rightMargin: 10
                            spacing: 12

                            Rectangle {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                radius: 8
                                color: entryItem.folderEntry
                                       ? "transparent"
                                       : (node.treeRoot.selectedPath === entryItem.entryPath
                                          ? node.treeRoot.selectedTextColor
                                          : node.treeRoot.textColor)
                                border.color: node.treeRoot.selectedPath === entryItem.entryPath
                                              ? node.treeRoot.selectedTextColor
                                              : node.treeRoot.mutedTextColor
                                border.width: 1

                                Rectangle {
                                    visible: entryItem.folderEntry
                                    width: 8
                                    height: 2
                                    radius: 1
                                    x: Math.round((parent.width - width) / 2)
                                    y: Math.round((parent.height - height) / 2)
                                    color: node.treeRoot.selectedPath === entryItem.entryPath
                                           ? node.treeRoot.selectedTextColor
                                           : (mouseArea.containsMouse
                                              ? node.treeRoot.hoverTextColor
                                              : node.treeRoot.textColor)
                                }

                                Rectangle {
                                    visible: entryItem.folderEntry
                                             && !node.treeRoot.isExpanded(entryItem.entryPath)
                                    width: 2
                                    height: 8
                                    radius: 1
                                    x: Math.round((parent.width - width) / 2)
                                    y: Math.round((parent.height - height) / 2)
                                    color: node.treeRoot.selectedPath === entryItem.entryPath
                                           ? node.treeRoot.selectedTextColor
                                           : (mouseArea.containsMouse
                                              ? node.treeRoot.hoverTextColor
                                              : node.treeRoot.textColor)
                                }
                            }

                            Label {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                elide: Text.ElideRight
                                text: fileName
                                color: node.treeRoot.selectedPath === entryItem.entryPath
                                       ? node.treeRoot.selectedTextColor
                                        : (mouseArea.containsMouse
                                        ? node.treeRoot.hoverTextColor
                                        : node.treeRoot.textColor)
                                font.pointSize: 11
                                font.bold: entryItem.folderEntry
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            hoverEnabled: true

                            onClicked: {
                                node.treeRoot.selectedPath = entryItem.entryPath

                                if (entryItem.folderEntry) {
                                    node.treeRoot.setExpanded(entryItem.entryPath,
                                                              !node.treeRoot.isExpanded(entryItem.entryPath))
                                }
                            }

                            onDoubleClicked: {
                                node.treeRoot.selectedPath = entryItem.entryPath

                                if (entryItem.folderEntry) {
                                    node.treeRoot.setExpanded(entryItem.entryPath, true)
                                    node.treeRoot.dirSelected(entryItem.entryPath)
                                } else {
                                    node.treeRoot.fileSelected(entryItem.entryPath)
                                }
                            }
                        }
                    }

                    Loader {
                        id: childLoader
                        active: entryItem.folderEntry && node.treeRoot.isExpanded(entryItem.entryPath)
                        visible: active
                        width: parent.width
                        height: item ? item.implicitHeight : 0
                        source: "DirTreeNode.qml"

                        onLoaded: {
                            item.treeRoot = node.treeRoot
                            item.folder = entryItem.entryPath
                            item.depth = node.depth + 1
                            item.width = Qt.binding(function() {
                                return parent.width
                            })
                        }
                    }
                }
            }
        }
    }
}