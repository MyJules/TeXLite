import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

ApplicationWindow {
    id: root
    visible: true

    title: "TeXLite"

    width: 1280
    height: 720

    minimumWidth: 600
    minimumHeight: 400

    Material.theme: Material.Dark
    Material.accent: Material.BlueGrey

    header: Row {
        spacing: 5
        leftPadding: 5

        Button {
           font.pointSize: 10
           height: 30
           text: "File"
           onClicked:{
            filePopup.popup()
           }
           Menu {
                 id: filePopup
                 MenuItem { text: "Open" }
                 MenuItem { text: "Exit" }
             }
        }

        Button {
           font.pointSize: 10
           height: 30
           text: "Help"
           onClicked:{
            helpPopup.popup()
           }
           Menu {
                 id: helpPopup
                 MenuItem { text: "About" }
             }
        }
    }

    footer: Row {
        spacing: 10
        leftPadding: 5

        Text {
           anchors.verticalCenter: parent.verticalCenter
           font.pointSize: 10
           height: 20
           text: "No Project"
           color: "white"
        }

    }


    SplitView {
        id: rowLayout
        clip: true
        anchors.fill: parent
        orientation: Qt.Horizonta

        Rectangle {
            id: fileSystem
            color: "#3F51B5"
            SplitView.preferredWidth: 120
            SplitView.minimumWidth: 80
        }

        Rectangle {
            id: latexTextRect
            color: "#607D8B"
            SplitView.preferredWidth: 400
            SplitView.minimumWidth: 200

            ScrollView {
                id: latexTextAreaScrollView
                anchors.fill: parent

                TextArea {
                    id: latexTextArea
                    focus: true
                    wrapMode: TextEdit.Wrap
                    font.pointSize: 12

                    text:
'\\documentclass{article}

\\title{Hello TeXLite}
\\author{Best User}
\\date{\\today}

\\begin{document}

\\maketitle

\\end{document}'
                }
            }
        }

        Rectangle {
            id: latexPDF
            color: "#EEEEEE"
            SplitView.fillWidth: true
            SplitView.preferredWidth: 400
            SplitView.minimumWidth: 200
        }
     }
}
