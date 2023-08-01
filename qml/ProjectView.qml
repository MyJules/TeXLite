import QtQuick
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

Item {
    id: root

    signal newFileSelected(string fileName)
    signal newProjectCreated(string projectPath)

    RowLayout {
        anchors.fill: parent

        ColumnLayout {
            Layout.fillWidth: true
            Layout.maximumWidth: 300

            Button {
                text: "Open File"
                flat: true
                Layout.fillWidth: true
                Material.roundedScale: Material.ExtraSmallScale

                onClicked: {
                    openFileDialog.open()
                }

                FileDialog {
                    id: openFileDialog
                    title: "Please choose a file"
                    fileMode: FileDialog.OpenFile

                    onAccepted: newFileSelected(openFileDialog.selectedFile)
                }
            }

            Button {
                text: "Create project"
                flat: true
                Layout.fillWidth: true
                Material.roundedScale: Material.ExtraSmallScale
            }
        }

        Rectangle {
            color: '#b3b3b3'
            clip: true

            Layout.fillWidth: true
            Layout.fillHeight: true

            Image {

                fillMode: Image.PreserveAspectFit
                source: "qrc:///icons/imgs/icon.png"
                scale: 0.2
                smooth: true
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
