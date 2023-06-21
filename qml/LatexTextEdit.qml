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
        onHighlightBlock: function (text) {
            let rx = /\/\/.*|[A-Za-z.]+(\s*:)?|\d+(.\d*)?|'[^']*?'|"[^"]*?"/g
            let m
            while ((m = rx.exec(text)) != null) {
                if (text.match(/\\documentclass\b/)) {
                    setFormat(m.index, m[0].length, headerFormat)
                }

                if (text.match(/\\begin\{.*\}/)) {
                    setFormat(m.index, m[0].length, environmentBeginFormat)
                }

                if (text.match(/\\end\{.*\}/)) {
                    setFormat(m.index, m[0].length, environmentEndFormat)
                }

                if (text.match(/\\[a-zA-Z]+\b/)) {
                    setFormat(m.index, m[0].length, commandFormat)
                }

                if (text.match(/{.*?}/)) {
                    setFormat(m.index, m[0].length, groupFormat)
                }

                if (text.match(/%.*$/)) {
                    setFormat(m.index, m[0].length, commentFormat)
                }
            }
        }
    }

    TextCharFormat {
        id: headerFormat
        foreground: "blue"
    }

    TextCharFormat {
        id: environmentBeginFormat
        foreground: "green"
    }

    TextCharFormat {
        id: environmentEndFormat
        foreground: "green"
    }

    TextCharFormat {
        id: commandFormat
        foreground: "red"
    }

    TextCharFormat {
        id: groupFormat
        foreground: "#3399ff"
    }

    TextCharFormat {
        id: commentFormat
        foreground: "gray"
    }
}
