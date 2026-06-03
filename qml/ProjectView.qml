import QtQuick
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

Item {
    id: root

    signal newFileSelected(string fileName)
    signal createExampleProjectRequested(string exampleId, string targetDir)

    property string selectedExampleProjectId: ""

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

                onClicked: openFileDialog.open()
            }

            Button {
                text: "Create Example Project"
                flat: true
                Layout.fillWidth: true
                Layout.leftMargin: 4
                font.pointSize: 10
                Material.roundedScale: Material.ExtraSmallScale

                onClicked: exampleProjectMenu.popup()
            }

            Menu {
                id: exampleProjectMenu

                MenuItem {
                    text: "Article"
                    font.pointSize: 10
                    onClicked: {
                        root.selectedExampleProjectId = "article"
                        createExampleProjectDialog.open()
                    }
                }

                MenuItem {
                    text: "Report"
                    font.pointSize: 10
                    onClicked: {
                        root.selectedExampleProjectId = "report"
                        createExampleProjectDialog.open()
                    }
                }

                MenuItem {
                    text: "Beamer Presentation"
                    font.pointSize: 10
                    onClicked: {
                        root.selectedExampleProjectId = "beamer"
                        createExampleProjectDialog.open()
                    }
                }
            }

            FileDialog {
                id: openFileDialog
                title: "Please choose a file"
                fileMode: FileDialog.OpenFile

                onAccepted: newFileSelected(openFileDialog.selectedFile)
            }

            FolderDialog {
                id: createExampleProjectDialog
                title: "Select a folder for the example project"

                onAccepted: createExampleProjectRequested(root.selectedExampleProjectId,
                                                          createExampleProjectDialog.selectedFolder)
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
