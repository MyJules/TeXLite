import QtQuick
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

Item {
    id: root

    signal newFileSelected(string fileName)

    RowLayout {
        anchors.fill: parent

        ColumnLayout {
            Layout.fillWidth: true
            Layout.maximumWidth: 380

            Button {
                text: "Open Project"
                flat: true
                Layout.fillWidth: true
                Layout.leftMargin: 4
                font.pointSize: 10
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
        }

        Rectangle {
            color: '#b3b3b3'
            clip: true
            radius: 3
            Layout.rightMargin: 4

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
