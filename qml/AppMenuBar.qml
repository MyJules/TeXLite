import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Controls.Material 2.15

Row {
    id: root

    signal compileClicked
    signal createNewFileClicked(string fileName)
    signal saveFileClicked
    signal newFileSelected(string fileName)
    signal saveDocumentClicked
    signal closeFileClicked

    property alias saveDocumentButtonEnabled: saveDocumentButton.enabled
    property alias comileButtonEnabled: compileButton.enabled
    property alias saveButtonEnabled: saveFileButton.enabled
    property alias closeButtonEnabled: closeFileButton.enabled

    Shortcut {
        context: Qt.ApplicationShortcut
        sequences: [StandardKey.Save]

        onActivated: saveFileClicked()
    }

    Shortcut {
        context: Qt.ApplicationShortcut
        sequences: [StandardKey.Open]

        onActivated: openFileDialog.open()
    }

    Shortcut {
        context: Qt.ApplicationShortcut
        sequences: [StandardKey.New]

        onActivated: newFileDialog.open()
    }

    ToolButton {
        flat: true
        font.pointSize: 10
        height: 30
        text: "File"
        onClicked: {
            filePopup.popup()
        }

        Menu {
            id: filePopup

            MenuItem {
                text: "New File"
                font.pointSize: 10
                onClicked: newFileDialog.open()

                FileDialog {
                    id: newFileDialog
                    title: "New File"
                    fileMode: FileDialog.SaveFile

                    onAccepted: {
                        createNewFileClicked(newFileDialog.selectedFile)
                    }
                }
            }

            MenuItem {
                text: "Open File"
                font.pointSize: 10
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

            MenuItem {
                id: saveFileButton
                font.pointSize: 10
                text: "Save File"

                onClicked: {
                    saveFileClicked()
                }
            }

            MenuSeparator {}

            MenuItem {
                id: closeFileButton
                font.pointSize: 10
                text: "Close File"
                onClicked: {
                    closeFileClicked()
                }
            }
            MenuSeparator {}

            MenuItem {
                text: "Exit"
                font.pointSize: 10
                onClicked: Qt.quit()
            }
        }
    }

    ToolButton {
        id: saveDocumentButton
        flat: true
        height: 30
        font.pointSize: 10
        text: "Save Document"
        onClicked: saveDocumentClicked()
    }

    ToolButton {
        flat: true
        height: 30
        font.pointSize: 10
        text: "Help"
        onClicked: helpPopup.popup()

        Menu {
            id: helpPopup
            MenuItem {
                text: "About"
                font.pointSize: 10
                onClicked: {
                    helpMessage.open()
                }
            }

            MessageDialog {
                id: helpMessage
                title: "About"
                text: "My simple LaTeX app, made with Qt 6, please be gentle."
                buttons: MessageDialog.Ok
            }
        }
    }

    ToolButton {
        id: compileButton
        flat: true
        height: 30
        font.pointSize: 10
        text: "Compile"
        onClicked: compileClicked()
    }
}
