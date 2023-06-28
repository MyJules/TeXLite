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
            sortField: FolderListModel.Type
        }

        Component {
            id: fileDelegate
            Row {
                ToolButton {
                    width: listView.width
                    text: fileName
                    flat: true

                    onClicked: {
                        listView.currentIndex = index
                    }

                    onDoubleClicked: {
                        if (folderModel.isFolder(index)) {
                            dirSelected(directory + "/" + text)
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
                color: "#0088cc"
            }
        }

        model: folderModel
        delegate: fileDelegate
        highlight: highlightDelegate
        highlightMoveDuration: 100
        highlightMoveVelocity: 100
    }
}
