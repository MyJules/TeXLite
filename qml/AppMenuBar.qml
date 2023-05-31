import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Controls.Material
import com.tex

Row {
    id: root

    signal newFileSelected(string file)
    signal newEngineSelected(string engineName)

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
            }

            MenuSeparator {}

            MenuItem {
                text: "Open File"
                onClicked: {
                    fileDialog.open()
                }

                FileDialog {
                    id: fileDialog
                    title: "Please choose a file"

                    onAccepted: {
                        newFileSelected(fileDialog.selectedFile)
                    }
                }
            }

            MenuItem {
                text: "Open Folder"
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
        onClicked: {
            latexEndginePopup.popup()
        }

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

                onCurrentValueChanged: {
                    newEngineSelected(latexEngineComboBox.currentValue)
                }
            }
        }
    }

    ToolButton {
        flat: true
        height: 30
        font.pointSize: 10
        text: "Help"
        onClicked: {
            helpPopup.popup()
        }

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
}
