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

    function removeText(start, end) {
        latexTextArea.remove(start, end)
    }

    function selectColsestWord() {
        latexTextArea.selectWord()
        return latexTextArea.selectedText
    }

    function deselectText() {
        latexTextArea.deselect()
    }

    signal dCursorPositionChanged

    property alias text: latexTextArea.text
    property alias textFocus: latexTextArea.focus
    property alias cursorPosition: latexTextArea.cursorPosition
    property alias textCursorVisible: latexTextArea.cursorVisible
    property alias textPointSize: latexTextArea.font.pointSize
    property int cursorLine: 0
    property int cursorX: 0
    property int cursorY: 0
    property real lineGapSize: 1
    property int areaLineCount: 0
    property real scrolledLines: 0

    ScrollView {
        id: latexTextAreaScrollView
        anchors.fill: parent
        clip: true

        ScrollBar.vertical.onPositionChanged: {
            calculateCoords()
            dCursorPositionChanged()
        }

        TextArea {
            id: latexTextArea
            focus: true
            font.pointSize: 12
            selectByMouse: true
            wrapMode: TextEdit.NoWrap
            placeholderText: "LaTeX Editor"

            onCursorPositionChanged: {
                calculateCoords()
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

    function calculateCoords() {
        let scrolledPositionX = latexTextAreaScrollView.ScrollBar.horizontal.position
        let scrolledPositionY = latexTextAreaScrollView.ScrollBar.vertical.position
        var scrolledLineX = (scrolledPositionX * latexTextArea.contentWidth)
        var scrolledLineY = (scrolledPositionY * latexTextArea.contentHeight)
        var zeroRect = latexTextArea.positionToRectangle(0)

        cursorLine = (latexTextArea.cursorRectangle.y - zeroRect.y)
                / (latexTextArea.cursorRectangle.height)

        lineGapSize = latexTextArea.cursorRectangle.height
        areaLineCount = root.height / lineGapSize

        scrolledLines = scrolledLineY / lineGapSize

        var mappedGlobal = latexTextArea.mapToGlobal(
                    latexTextArea.cursorRectangle.x,
                    latexTextArea.cursorRectangle.y)
        var mapped = root.mapFromGlobal(mappedGlobal.x, mappedGlobal.y)
        cursorX = mapped.x
        cursorY = mapped.y
    }
}
