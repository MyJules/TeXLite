import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material

import com.file
import com.highliter

Rectangle {
    id: root
    color: "#292929"
    clip: true

    function insertText(position, text) {
        latexTextArea.insert(position, text)
    }

    signal dCursorPositionChanged

    property alias text: latexTextArea.text
    property alias textFocus: latexTextArea.focus
    property alias cursorPosition: latexTextArea.cursorPosition
    property int cursorX: 0
    property int cursorY: 0

    ScrollView {
        id: latexTextAreaScrollView
        anchors.fill: parent
        clip: true

        TextArea {
            id: latexTextArea
            focus: true
            font.pointSize: 12
            selectByMouse: true
            wrapMode: TextEdit.WordWrap

            onCursorPositionChanged: {
                let scrolledPositionX = latexTextAreaScrollView.ScrollBar.horizontal.position
                let scrolledPositionY = latexTextAreaScrollView.ScrollBar.vertical.position
                var scrolledLineX = (scrolledPositionX * latexTextArea.contentWidth)
                var scrolledLineY = (scrolledPositionY * latexTextArea.contentHeight)

                cursorX = latexTextArea.positionToRectangle(
                            latexTextArea.cursorPosition).x - scrolledLineX

                cursorY = latexTextArea.positionToRectangle(
                            latexTextArea.cursorPosition).y - scrolledLineY
                dCursorPositionChanged()
            }
        }
    }

    SyntaxHighlighter {
        id: syntaxHighlighter
        textDocument: latexTextArea.textDocument
        onHighlightBlock: function (text) {
            let rx = /\/\/.*|[A-Za-z.]+(\s*:)?|\d+(.\d*)?|'[^']*?'|"[^"]*?"/g
            let m
            while ((m = rx.exec(text)) != null) {
                if (text.match(/\\[a-zA-Z]+\b/)) {
                    setFormat(m.index, m[0].length, commandFormat)
                }

                if (text.match(/{.*?}/)) {
                    setFormat(m.index, m[0].length, groupFormat)
                }

                if (text.match(/%.*$/)) {
                    setFormat(m.index, m[0].length, commentFormat)
                }

                if (text.match(/\\documentclass\b/)) {
                    setFormat(m.index, m[0].length, headerFormat)
                }

                if (text.match(/\\usepackage\b/)) {
                    setFormat(m.index, m[0].length, headerFormat)
                }
            }
        }
    }

    TextCharFormat {
        id: headerFormat
        foreground: "#ff4d4d"
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
        foreground: "#ff8080"
    }

    TextCharFormat {
        id: groupFormat
        foreground: "#809fff"
    }

    TextCharFormat {
        id: commentFormat
        foreground: "gray"
    }
}
