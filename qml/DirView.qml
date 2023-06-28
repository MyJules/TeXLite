import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt.labs.folderlistmodel

Item {
    id: root

    signal onNewFileSelected(string filePath)

    property alias directory: folderModel.folder

    ListView {
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
                Rectangle {
                    width: 45
                    height: parent.height
                    color: "#cccccc"
                }

                ToolButton {
                    text: fileName
                    flat: true
                }
            }
        }

        model: folderModel
        delegate: fileDelegate
    }
}
