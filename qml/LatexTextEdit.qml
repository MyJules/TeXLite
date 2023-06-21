import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material

import com.file
import com.highliter

Rectangle {
    id: latexTextRect
    color: "#292929"
    radius: 4
    clip: true

    property alias text: latexTextArea.text

    ScrollView {
        id: latexTextAreaScrollView
        anchors.fill: parent
        clip: true

        TextEdit {
            id: latexTextArea
            focus: true
            font.pointSize: 12
            selectByMouse: true
            textMargin: 10.0
            color: "white"
        }
    }

    SyntaxHighlighter {
        id: syntaxHighlighter
        textDocument: latexTextArea.textDocument
        onHighlightBlock: {
            let rx = /\/\/.*|[A-Za-z.]+(\s*:)?|\d+(.\d*)?|'[^']*?'|"[^"]*?"/g
            let m
            while ((m = rx.exec(text)) !== null) {
                if (m[0].match(/^'/)) {
                    setFormat(m.index, m[0].length, stringFormat)
                    continue
                }

                if (m[0].match(/^"/)) {
                    setFormat(m.index, m[0].length, stringFormat)
                    continue
                }
            }
        }
    }

    TextCharFormat {
        id: keywordFormat
        foreground: "#808000"
    }
    TextCharFormat {
        id: componentFormat
        foreground: "#aa00aa"
        font.pointSize: 12
        font.bold: true
        font.italic: true
    }
    TextCharFormat {
        id: numberFormat
        foreground: "#0055af"
    }
    TextCharFormat {
        id: propertyFormat
        foreground: "#800000"
    }
    TextCharFormat {
        id: stringFormat
        foreground: "green"
    }
    TextCharFormat {
        id: commentFormat
        foreground: "green"
    }
}
