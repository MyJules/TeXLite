import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material 2.15

Row {
    spacing: 5
    leftPadding: 5

    Button {
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

    Button {
       flat: true
       font.pointSize: 10
       height: 30
       text: "Help"
       onClicked:{
        helpPopup.popup()
       }
       Menu {
             id: helpPopup
             MenuItem {
                text: "About"
             }
         }
    }
}

