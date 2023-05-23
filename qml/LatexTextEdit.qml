import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material

Rectangle {
    id: latexTextRect
    color: "#292929"
    clip: true

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
