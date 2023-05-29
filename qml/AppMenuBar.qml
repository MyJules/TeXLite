import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Controls.Material
import com.tex

Row {
    id: root

    signal compiled(string texFileName)
    property TexEngine currentEngine: pdfLatexEngine
    property string tempFileName: "temp.tex"

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
                        text: "pdfTeX"
                    }
                    ListElement {
                        text: "pdfLaTeX"
                    }
                }

                onCurrentValueChanged: {
                    switch (latexEngineComboBox.currentValue) {
                    case pdfLatexEngine.texEngineCommand:
                        root.currentEngine = pdfLatexEngine
                        break
                    default:
                        root.currentEngine = pdfLatexEngine
                        break
                    }
                }
            }
        }

        TexEngine {
            id: pdfLatexEngine
            texEngineCommand: "pdfLaTeX"
            texEngineArguments: [tempFileName, "-quiet"]
            onStateChanged: {
                console.log(pdfLatexEngine.state)
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

    ToolButton {
        flat: true
        height: 30
        font.pointSize: 10
        text: "Compile"
        onClicked: {
            currentEngine.execute()
            compiled(tempFileName)
        }
    }
}
