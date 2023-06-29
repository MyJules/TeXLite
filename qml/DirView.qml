import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt.labs.folderlistmodel

Item {
    id: root

    signal fileSelected(string filePath)
    signal dirSelected(string dirPath)

    property alias directory: folderModel.folder

    ListView {
        id: listView
        anchors.fill: parent
        spacing: 5

        FolderListModel {
            id: folderModel
            showDirsFirst: true
            showDotAndDotDot: true
            sortField: FolderListModel.Type
            nameFilters: ["*.tex"]
        }

        Component {
            id: fileDelegate
            Row {

                Component.onCompleted: {
                    if (folderModel.isFolder(index)) {
                        backgrounRect.color = "#800066ff"
                    }
                }

                ToolButton {
                    id: toolButton
                    width: listView.width
                    flat: true
                    text: fileName
                    font.pointSize: 10

                    background: Rectangle {
                        id: backgrounRect
                        color: "transparent"
                    }

                    onClicked: {
                        listView.currentIndex = index
                    }

                    onDoubleClicked: {
                        if (folderModel.isFolder(index)) {
                            if (text == "..") {
                                dirSelected(folderModel.parentFolder)
                            } else {
                                dirSelected(directory + "/" + text)
                            }
                        } else {
                            fileSelected(directory + "/" + text)
                        }
                    }
                }
            }
        }

        Component {
            id: highlightDelegate
            Rectangle {
                color: "#1a75ff"
            }
        }

        model: folderModel
        delegate: fileDelegate
        highlight: highlightDelegate
        highlightMoveDuration: 10
        //        highlightMoveVelocity: 100
        highlightResizeDuration: 0
    }
}
