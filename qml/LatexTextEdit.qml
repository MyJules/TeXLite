import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Rectangle {
    id: latexTextRect
    color: "#292929"
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
