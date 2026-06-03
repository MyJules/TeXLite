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
    property var exampleProjects: [
        {
            id: "article",
            title: "Article",
            description: "A simple document with sections and equations."
        },
        {
            id: "report",
            title: "Report",
            description: "A longer template with chapters and contents."
        },
        {
            id: "beamer",
            title: "Beamer Presentation",
            description: "Slides for talks, demos, and short presentations."
        }
    ]

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

                onClicked: openProjectDialog.open()
            }

            Button {
                text: "Create Example Project"
                flat: true
                Layout.fillWidth: true
                Layout.leftMargin: 4
                font.pointSize: 10
                Material.roundedScale: Material.ExtraSmallScale

                onClicked: exampleProjectDialog.open()
            }

            FileDialog {
                id: openFileDialog
                title: "Open Project"
                fileMode: FileDialog.OpenFile
                nameFilters: ["TeX files (*.tex)", "All files (*)"]

                onAccepted: newFileSelected(openFileDialog.selectedFile)
            }

            Dialog {
                id: openProjectDialog
                title: "Open Project"
                anchors.centerIn: Overlay.overlay
                width: 460
                modal: true
                standardButtons: Dialog.Cancel
                Material.roundedScale: Material.ExtraSmallScale

                contentItem: ColumnLayout {
                    width: 420
                    spacing: 14

                    Label {
                        Layout.fillWidth: true
                        text: "Choose a LaTeX file to open as the main project file."
                        color: "#c9c9c9"
                        font.pointSize: 10
                        wrapMode: Text.WordWrap
                    }

                    ItemDelegate {
                        Layout.fillWidth: true
                        padding: 16

                        background: Rectangle {
                            radius: 10
                            color: parent.hovered ? "#3a3a3a" : "#2f2f2f"
                            border.color: "#4a4a4a"
                        }

                        contentItem: Column {
                            spacing: 6

                            Label {
                                text: "Browse For Project File"
                                color: "#f0f0f0"
                                font.pointSize: 12
                                font.bold: true
                            }

                            Label {
                                text: "Pick the main .tex file for the project, such as main.tex."
                                color: "#c9c9c9"
                                font.pointSize: 10
                                wrapMode: Text.WordWrap
                            }
                        }

                        onClicked: {
                            openProjectDialog.close()
                            openFileDialog.open()
                        }
                    }
                }
            }

            FolderDialog {
                id: createExampleProjectDialog
                title: "Select a folder for the example project"

                onAccepted: createExampleProjectRequested(root.selectedExampleProjectId,
                                                          createExampleProjectDialog.selectedFolder)
            }

            Dialog {
                id: exampleProjectDialog
                title: "Choose Example Project"
                anchors.centerIn: Overlay.overlay
                width: 460
                modal: true
                standardButtons: Dialog.Cancel
                Material.roundedScale: Material.ExtraSmallScale

                contentItem: ListView {
                    id: exampleProjectList
                    clip: true
                    implicitHeight: contentHeight
                    implicitWidth: 420
                    spacing: 12
                    model: root.exampleProjects

                    delegate: ItemDelegate {
                        required property var modelData

                        width: exampleProjectList.width
                        padding: 16

                        background: Rectangle {
                            radius: 10
                            color: parent.hovered ? "#3a3a3a" : "#2f2f2f"
                            border.color: "#4a4a4a"
                        }

                        contentItem: Column {
                            spacing: 6

                            Label {
                                text: modelData.title
                                color: "#f0f0f0"
                                font.pointSize: 12
                                font.bold: true
                            }

                            Label {
                                text: modelData.description
                                color: "#c9c9c9"
                                font.pointSize: 10
                                wrapMode: Text.WordWrap
                            }
                        }

                        onClicked: {
                            root.selectedExampleProjectId = modelData.id
                            exampleProjectDialog.close()
                            createExampleProjectDialog.open()
                        }
                    }
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
