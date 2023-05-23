import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Controls.Material

Row {
    ToolButton {
       flat: true
       font.pointSize: 10
       height: 30
       text: "File"
       onClicked:{
        filePopup.popup()
       }

       Menu {
             id: filePopup

             MenuItem {
                text: "New File"
             }

             MenuSeparator{}

             MenuItem {
                 text: "Open File"
             }

             MenuItem {
                 text: "Open Folder"
             }

             MenuSeparator{}

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

