import QtQuick
import QtQuick.Controls
import Qt.labs.folderlistmodel
import QtQuick.Controls.Material

Rectangle {
    id: fileSystem

    ListView {
        anchors.fill: parent

        FolderListModel {
            id: folderModel
            showDirs: true
            showDirsFirst: true
            nameFilters: ["*.*"]
        }

        Component {
            id: fileDelegate
            Button{
                flat: true
                text: fileName
                height: 30
            }
        }

        model: folderModel
        delegate: fileDelegate
    }
}
