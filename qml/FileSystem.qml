import QtQuick
import QtQuick.Controls
import Qt.labs.folderlistmodel
import QtQuick.Controls.Material 2.15

Rectangle {
    id: fileSystem
    color: "#171b40"
    SplitView.preferredWidth: 120
    SplitView.minimumWidth: 100

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
