import QtQuick
import QtCore
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts

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
    property alias compileOnSaveEnabled: compileOnSaveMenuItem.checked

    Settings {
        category: "AppMenuBar"
        property alias compileOnSaveEnabled: compileOnSaveMenuItem.checked
    }

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

    function togglePopup(popup) {
        if (popup.opened)
            popup.close()
        else
            popup.openAnchored()
    }

    ToolButton {
        id: fileButton
        flat: true
        font.pointSize: 10
        height: 30
        text: "File"
        onClicked: root.togglePopup(filePopup)

        AppPopupMenu {
            id: filePopup
            anchorItem: fileButton
            menuWidth: 210

            AppMenuItem {
                text: "New File"
                onClicked: {
                    filePopup.close()
                    newFileDialog.open()
                }

                FileDialog {
                    id: newFileDialog
                    title: "New File"
                    fileMode: FileDialog.SaveFile

                    onAccepted: {
                        createNewFileClicked(newFileDialog.selectedFile)
                    }
                }
            }

            AppMenuItem {
                text: "Open File"
                onClicked: {
                    filePopup.close()
                    openFileDialog.open()
                }

                FileDialog {
                    id: openFileDialog
                    title: "Please choose a file"
                    fileMode: FileDialog.OpenFile

                    onAccepted: newFileSelected(openFileDialog.selectedFile)
                }
            }

            AppMenuItem {
                id: saveFileButton
                text: "Save File"

                onClicked: {
                    filePopup.close()
                    saveFileClicked()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#343434"
            }

            AppMenuItem {
                id: closeFileButton
                text: "Close File"
                onClicked: {
                    filePopup.close()
                    closeFileClicked()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#343434"
            }

            AppMenuItem {
                text: "Exit"
                onClicked: {
                    filePopup.close()
                    Qt.quit()
                }
            }
        }
    }

    ToolButton {
        id: saveDocumentButton
        flat: true
        height: 30
        font.pointSize: 10
        text: "Save to PDF"
        onClicked: saveDocumentClicked()
    }

    ToolButton {
        id: settingsButton
        flat: true
        height: 30
        font.pointSize: 10
        text: "Settings"
        onClicked: root.togglePopup(settingsPopup)

        AppPopupMenu {
            id: settingsPopup
            anchorItem: settingsButton
            menuWidth: 220

            AppMenuItem {
                id: compileOnSaveMenuItem
                text: "Compile On Save"
                checkable: true
                checked: true
            }
        }
    }

    ToolButton {
        id: helpButton
        flat: true
        height: 30
        font.pointSize: 10
        text: "Help"
        onClicked: root.togglePopup(helpPopup)

        AppPopupMenu {
            id: helpPopup
            anchorItem: helpButton
            menuWidth: 200

            AppMenuItem {
                text: "About"
                onClicked: {
                    helpPopup.close()
                    helpMessage.open()
                }
            }
        }
    }

    AppMessageDialog {
        id: helpMessage
        title: "About"
        text: "My simple LaTeX app, made with Qt 6, please be gentle."
        buttons: Dialog.Ok
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
