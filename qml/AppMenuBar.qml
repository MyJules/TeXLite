import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Controls.Material

Row {
    id: root

    signal createNewFileClicked
    signal saveFileClicked
    signal newFileSelected(string fileName)
    signal newEngineSelected(string engineName)
    signal compileClicked

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

        onActivated: createNewFileClicked()
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
                onClicked: createNewFileClicked
            }

            MenuSeparator {}

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

            MenuSeparator {}

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
                    ListElement {
                        text: "pdftex"
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
        onClicked: compileClicked
    }
}
