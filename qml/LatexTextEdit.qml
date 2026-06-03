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

    function buildLineNumberText() {
        const lineCount = Math.max(1, latexTextArea.text.split("\n").length)
        let numbers = ""

        for (let lineNumber = 1; lineNumber <= lineCount; ++lineNumber) {
            numbers += lineNumber

            if (lineNumber < lineCount)
                numbers += "\n"
        }

        return numbers
    }

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
    property real lineNumberOffsetY: latexTextArea.topPadding
                                     - (latexTextAreaScrollView.contentItem
                                        && latexTextAreaScrollView.contentItem.contentY
                                        ? latexTextAreaScrollView.contentItem.contentY : 0)
    property string lineNumbersText: buildLineNumberText()
    property int lineNumberDigits: Math.max(2, lineNumbersText.split("\n").length.toString().length)
    property real gutterDigitWidth: Math.max(8, textPointSize * 0.8)
    property int gutterWidth: Math.ceil(18 + (lineNumberDigits * gutterDigitWidth))

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: root.gutterWidth
            color: "#232323"
            border.color: "#313131"
            border.width: 1
            clip: true

            Text {
                id: lineNumbers
                visible: latexTextArea.length > 0
                anchors.right: parent.right
                anchors.rightMargin: 8
                readonly property int displayedLineCount: Math.max(1, root.lineNumbersText.split("\n").length)
                readonly property real lineContentHeight: paintedHeight / displayedLineCount
                readonly property real centeredOffset: Math.max(0,
                                                                (root.lineGapSize - lineContentHeight) / 2)
                y: root.lineNumberOffsetY + centeredOffset + 1
                text: root.lineNumbersText
                color: "#8f8f8f"
                font.pointSize: latexTextArea.font.pointSize
                font.family: "Consolas"
                horizontalAlignment: Text.AlignRight
                lineHeightMode: Text.FixedHeight
                lineHeight: Math.max(1, root.lineGapSize)
            }
        }

        ScrollView {
            id: latexTextAreaScrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
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

                onCursorPositionChanged: {
                    calculateCoords()
                    dCursorPositionChanged()
                }

                onTextChanged: {
                    root.lineNumbersText = root.buildLineNumberText()
                    calculateCoords()
                }

                onFontChanged: {
                    calculateCoords()
                }
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
        var zeroRect = latexTextArea.positionToRectangle(0)
        const contentY = latexTextAreaScrollView.contentItem
            && latexTextAreaScrollView.contentItem.contentY
            ? latexTextAreaScrollView.contentItem.contentY : 0

        cursorLine = (latexTextArea.cursorRectangle.y - zeroRect.y)
                / (latexTextArea.cursorRectangle.height)

        lineGapSize = latexTextArea.cursorRectangle.height
        areaLineCount = root.height / lineGapSize

        scrolledLines = contentY / lineGapSize

        var mappedGlobal = latexTextArea.mapToGlobal(
                    latexTextArea.cursorRectangle.x,
                    latexTextArea.cursorRectangle.y)
        var mapped = root.mapFromGlobal(mappedGlobal.x, mappedGlobal.y)
        cursorX = mapped.x
        cursorY = mapped.y
    }

    Component.onCompleted: {
        lineNumbersText = buildLineNumberText()
        calculateCoords()
    }
}
