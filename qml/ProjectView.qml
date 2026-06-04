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
    property bool compactLayout: width < 980
    property int pagePadding: compactLayout ? 16 : 32
    property int panelSpacing: compactLayout ? 16 : 28
    property int panelHeight: Math.max(420, height - pagePadding * 2)
    property color pageBackgroundTop: "#202020"
    property color pageBackgroundBottom: "#171717"
    property color panelColor: "#232323"
    property color panelAltColor: "#262626"
    property color borderColor: "#3a3a3a"
    property color mutedTextColor: "#b7b7b7"
    property color accentColor: "#d4d4d4"
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

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.pageBackgroundTop }
            GradientStop { position: 1.0; color: root.pageBackgroundBottom }
        }

        Rectangle {
            width: Math.max(220, parent.width * 0.34)
            height: width
            radius: width / 2
            color: "#2c2c2c"
            opacity: 0.28
            x: parent.width - width * 0.58
            y: -height * 0.22
        }

        Rectangle {
            width: Math.max(160, parent.width * 0.18)
            height: width
            radius: width / 2
            color: "#313131"
            opacity: 0.16
            x: -width * 0.25
            y: parent.height - height * 0.55
        }

        ScrollView {
            id: pageScrollView
            anchors.fill: parent
            anchors.margins: root.pagePadding
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Item {
                width: Math.max(pageScrollView.availableWidth, 320)
                implicitHeight: contentLayout.implicitHeight

                GridLayout {
                    id: contentLayout
                    width: parent.width
                    columns: root.compactLayout ? 1 : 2
                    rowSpacing: root.panelSpacing
                    columnSpacing: root.panelSpacing

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.compactLayout ? implicitHeight : root.panelHeight
                        radius: 24
                        color: root.panelColor
                        border.color: root.borderColor
                        border.width: 1
                        implicitHeight: primaryColumn.implicitHeight + (root.compactLayout ? 48 : 68)

                        ColumnLayout {
                            id: primaryColumn
                            anchors.fill: parent
                            anchors.margins: root.compactLayout ? 22 : 34
                            spacing: root.compactLayout ? 18 : 22

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Label {
                                    Layout.fillWidth: true
                                    text: "TeXLite"
                                    color: "#f4f4f4"
                                    font.pointSize: root.compactLayout ? 22 : 28
                                    font.bold: true
                                }

                                Label {
                                    Layout.fillWidth: true
                                    text: "Open an existing LaTeX project or start from a clean example template."
                                    color: root.mutedTextColor
                                    font.pointSize: 12
                                    wrapMode: Text.WordWrap
                                }
                            }


                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 14

                                ItemDelegate {
                                    Layout.fillWidth: true
                                    padding: root.compactLayout ? 16 : 20
                                    hoverEnabled: true

                                    background: Rectangle {
                                        radius: 18
                                        color: parent.down ? "#343434" : (parent.hovered ? "#313131" : "#2b2b2b")
                                        border.color: parent.hovered ? "#5a5a5a" : root.borderColor
                                        border.width: 1
                                    }

                                    contentItem: RowLayout {
                                        spacing: 14

                                        Rectangle {
                                            Layout.preferredWidth: 44
                                            Layout.preferredHeight: 44
                                            radius: 14
                                            color: "#383838"

                                            Label {
                                                anchors.centerIn: parent
                                                text: "O"
                                                color: root.accentColor
                                                font.pointSize: 14
                                                font.bold: true
                                            }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 4

                                            Label {
                                                Layout.fillWidth: true
                                                text: "Open Project"
                                                color: "#f1f1f1"
                                                font.pointSize: 13
                                                font.bold: true
                                            }

                                            Label {
                                                Layout.fillWidth: true
                                                text: "Select the main .tex file from an existing folder."
                                                color: root.mutedTextColor
                                                font.pointSize: 10.5
                                                wrapMode: Text.WordWrap
                                            }
                                        }

                                        Label {
                                            visible: !root.compactLayout
                                            text: "Browse"
                                            color: "#d0d0d0"
                                            font.pointSize: 10
                                            font.bold: true
                                            Layout.alignment: Qt.AlignVCenter
                                        }
                                    }

                                    onClicked: openProjectDialog.open()
                                }

                                ItemDelegate {
                                    Layout.fillWidth: true
                                    padding: root.compactLayout ? 16 : 20
                                    hoverEnabled: true

                                    background: Rectangle {
                                        radius: 18
                                        color: parent.down ? "#343434" : (parent.hovered ? "#313131" : "#2b2b2b")
                                        border.color: parent.hovered ? "#5a5a5a" : root.borderColor
                                        border.width: 1
                                    }

                                    contentItem: RowLayout {
                                        spacing: 14

                                        Rectangle {
                                            Layout.preferredWidth: 44
                                            Layout.preferredHeight: 44
                                            radius: 14
                                            color: "#383838"

                                            Label {
                                                anchors.centerIn: parent
                                                text: "E"
                                                color: root.accentColor
                                                font.pointSize: 14
                                                font.bold: true
                                            }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 4

                                            Label {
                                                Layout.fillWidth: true
                                                text: "Select Example Project"
                                                color: "#f1f1f1"
                                                font.pointSize: 13
                                                font.bold: true
                                            }

                                            Label {
                                                Layout.fillWidth: true
                                                text: "Start with an article, report, or presentation template."
                                                color: root.mutedTextColor
                                                font.pointSize: 10.5
                                                wrapMode: Text.WordWrap
                                            }
                                        }

                                        Label {
                                            visible: !root.compactLayout
                                            text: "Templates"
                                            color: "#d0d0d0"
                                            font.pointSize: 10
                                            font.bold: true
                                            Layout.alignment: Qt.AlignVCenter
                                        }
                                    }

                                    onClicked: exampleProjectDialog.open()
                                }
                            }

                            Item {
                                Layout.fillHeight: true
                            }

                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.compactLayout ? implicitHeight : root.panelHeight
                        radius: 24
                        color: "#1d1d1d"
                        border.color: root.borderColor
                        border.width: 1
                        clip: true
                        implicitHeight: secondaryColumn.implicitHeight + (root.compactLayout ? 48 : 60)

                        Item {
                            anchors.fill: parent

                            Rectangle {
                                width: parent.width * (root.compactLayout ? 0.56 : 0.72)
                                height: width
                                radius: width / 2
                                color: "#2a2a2a"
                                opacity: 0.45
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: -width * 0.16
                            }

                            ColumnLayout {
                                id: secondaryColumn
                                anchors.fill: parent
                                anchors.margins: root.compactLayout ? 22 : 30
                                spacing: root.compactLayout ? 16 : 20

                                Rectangle {
                                    Layout.preferredWidth: 120
                                    Layout.preferredHeight: 32
                                    radius: 16
                                    color: "#2a2a2a"
                                    border.color: "#353535"
                                    border.width: 1

                                    Label {
                                        anchors.centerIn: parent
                                        text: "LaTeX Ready"
                                        color: "#d5d5d5"
                                        font.pointSize: 10
                                        font.bold: true
                                    }
                                }

                                Item {
                                    Layout.fillHeight: true
                                    Layout.minimumHeight: root.compactLayout ? 0 : 12
                                }

                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: Math.min(parent.width - 24, root.compactLayout ? 200 : 280)
                                    Layout.preferredHeight: Layout.preferredWidth
                                    radius: root.compactLayout ? 24 : 28
                                    color: "#252525"
                                    border.color: "#333333"
                                    border.width: 1

                                    Image {
                                        anchors.centerIn: parent
                                        width: parent.width * 0.5
                                        height: width
                                        fillMode: Image.PreserveAspectFit
                                        source: "qrc:///icons/imgs/icon.png"
                                        smooth: true
                                    }
                                }

                                Item {
                                    Layout.fillHeight: true
                                    Layout.minimumHeight: root.compactLayout ? 0 : 12
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Label {
                                        Layout.fillWidth: true
                                        text: "Open fast. Stay focused."
                                        color: "#f0f0f0"
                                        font.pointSize: root.compactLayout ? 14 : 16
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: "Choose a project or template to jump straight into writing."
                                        color: root.mutedTextColor
                                        font.pointSize: 10.5

                                        wrapMode: Text.WordWrap
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
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
            padding: 0
            Material.roundedScale: Material.ExtraSmallScale

            header: Rectangle {
                implicitHeight: 52
                color: "#242424"
                radius: 12
                topLeftRadius: 12
                topRightRadius: 12
                bottomLeftRadius: 0
                bottomRightRadius: 0
                border.color: "#3a3a3a"
                border.width: 1

                Label {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    verticalAlignment: Text.AlignVCenter
                    text: openProjectDialog.title
                    color: "#f0f0f0"
                    font.pointSize: 12
                    font.bold: true
                    elide: Text.ElideRight
                }
            }

            background: Rectangle {
                radius: 12
                color: "#1d1d1d"
                border.color: "#3a3a3a"
                border.width: 1
            }

            contentItem: ColumnLayout {
                width: 420
                spacing: 14

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

            footer: DialogButtonBox {
                standardButtons: Dialog.Cancel
                spacing: 10
                padding: 14
                alignment: Qt.AlignRight

                background: Rectangle {
                    color: "#1d1d1d"
                    border.color: "#3a3a3a"
                    border.width: 1
                    radius: 12
                    topLeftRadius: 0
                    topRightRadius: 0
                    bottomLeftRadius: 12
                    bottomRightRadius: 12
                }

                delegate: Button {
                    flat: true
                    Material.roundedScale: Material.ExtraSmallScale

                    background: Rectangle {
                        radius: 8
                        color: down ? "#343434" : hovered ? "#2b2b2b" : "transparent"
                        border.color: "#4a4a4a"
                        border.width: 1
                    }

                    contentItem: Label {
                        text: parent.text
                        color: "#f0f0f0"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 10
                    }
                }

                onAccepted: openProjectDialog.accept()
                onRejected: openProjectDialog.reject()
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
            padding: 0
            Material.roundedScale: Material.ExtraSmallScale

            header: Rectangle {
                implicitHeight: 52
                color: "#242424"
                radius: 12
                topLeftRadius: 12
                topRightRadius: 12
                bottomLeftRadius: 0
                bottomRightRadius: 0
                border.color: "#3a3a3a"
                border.width: 1

                Label {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    verticalAlignment: Text.AlignVCenter
                    text: exampleProjectDialog.title
                    color: "#f0f0f0"
                    font.pointSize: 12
                    font.bold: true
                    elide: Text.ElideRight
                }
            }

            background: Rectangle {
                radius: 12
                color: "#1d1d1d"
                border.color: "#3a3a3a"
                border.width: 1
            }

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

            footer: DialogButtonBox {
                standardButtons: Dialog.Cancel
                spacing: 10
                padding: 14
                alignment: Qt.AlignRight

                background: Rectangle {
                    color: "#1d1d1d"
                    border.color: "#3a3a3a"
                    border.width: 1
                    radius: 12
                    topLeftRadius: 0
                    topRightRadius: 0
                    bottomLeftRadius: 12
                    bottomRightRadius: 12
                }

                delegate: Button {
                    flat: true
                    Material.roundedScale: Material.ExtraSmallScale

                    background: Rectangle {
                        radius: 8
                        color: down ? "#343434" : hovered ? "#2b2b2b" : "transparent"
                        border.color: "#4a4a4a"
                        border.width: 1
                    }

                    contentItem: Label {
                        text: parent.text
                        color: "#f0f0f0"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 10
                    }
                }

                onAccepted: exampleProjectDialog.accept()
                onRejected: exampleProjectDialog.reject()
            }
        }
    }
}
