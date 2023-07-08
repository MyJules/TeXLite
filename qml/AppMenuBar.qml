import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Controls.Material

Row {
    id: root

    signal compileClicked
    signal createNewFileClicked(string fileName)
    signal saveFileClicked
    signal newFileSelected(string fileName)
    signal newEngineSelected(string engineName)
    signal saveDocumentClicked(string fileName)

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
                text: "Save File"

                onClicked: {
                    saveFileClicked()
                }
            }

            MenuSeparator {}

            MenuItem {
                text: "Exit"
                onClicked: Qt.quit()
            }
        }
    }

    ToolButton {
        flat: true
        height: 30
        font.pointSize: 10
        text: "Document"
        onClicked: docementMenu.open()

        Menu {
            id: docementMenu

            MenuItem {
                text: "Save document"
                onClicked: saveDocumentDialog.open()

                FileDialog {
                    id: saveDocumentDialog
                    title: "Save PDF document"
                    fileMode: FileDialog.SaveFile

                    onAccepted: saveDocumentClicked(
                                    saveDocumentDialog.selectedFile)
                }
            }
        }
    }

    ToolButton {
        flat: true
        height: 30
        font.pointSize: 10
        text: "LaTeX Engine"
        onClicked: latexEndginePopup.popup()

        Menu {
            id: latexEndginePopup
            ComboBox {
                id: latexEngineComboBox
                model: ListModel {
                    id: model
                    ListElement {
                        text: "pdflatex"
                    }
                }

                onCurrentValueChanged: newEngineSelected(
                                           latexEngineComboBox.currentValue)
            }
        }
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
        flat: true
        height: 30
        font.pointSize: 10
        text: "Compile"
        onClicked: compileClicked()
    }
}
