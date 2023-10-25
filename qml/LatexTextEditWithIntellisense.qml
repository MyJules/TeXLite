import QtQuick

LatexTextEdit {
    id: root

    Shortcut {
        sequence: "F2"
        onActivated: {
            if (root.textPointSize > 19)
                return

            root.textPointSize += 1
        }
    }

    Shortcut {
        sequence: "F1"
        onActivated: {
            if (root.textPointSize < 6)
                return

            root.textPointSize -= 1
        }
    }

    onDCursorPositionChanged: {
        if (!intellisense.opened)
            return

        placeIntelisense(root.cursorX, root.cursorY)
    }

    IntellisenseMenu {
        id: intellisense

        onKeyPreseed: function (key, text) {
            switch (key) {
            case Qt.Key_Left:
                root.cursorPosition--
                break
            case Qt.Key_Right:
                root.cursorPosition++
                break
            case Qt.Key_Backspace:
                root.removeText(root.cursorPosition - 1, root.cursorPosition)
                intellisense.searchWord = intellisense.searchWord.substring(
                            0, intellisense.searchWord.length - 1)
                break
            case Qt.Key_Escape:
                break
                //Qt.Key_Enter
            case 16777220:
                break
            case Qt.Key_Space:
                intellisense.close()
                root.insertText(root.cursorPosition, text)
                break
            default:
                root.insertText(root.cursorPosition, text)
                intellisense.searchWord += text
                break
            }
        }

        onIntelisenceActivated: {
            intellisense.searchWord = root.selectColsestWord()
            placeIntelisense(root.cursorX, root.cursorY)
            intellisense.focus = true
            intellisense.open()
        }

        onIntelisenseDisactivated: {
            root.deselectText()
        }

        onKeywordSelected: function (keyword) {
            root.removeText(
                        root.cursorPosition - intellisense.searchWord.length,
                        root.cursorPosition)
            root.insertText(root.cursorPosition, keyword)
            intellisense.focus = false
            intellisense.close()
            latexTextEdit.textFocus = true
        }
    }

    function placeIntelisense(x, y) {
        let farRight = x + intellisense.width - 12
        let farBottom = y + intellisense.height + 10

        if (farRight > root.width - 12) {
            x += (root.width - farRight)
        }

        if (farBottom > root.height + 10) {
            y += (root.height - farBottom)
        }

        if (x < -12) {
            y = 12
        }

        if (y < 10) {
            y = 10
        }

        intellisense.x = x - 12
        intellisense.y = y + 10
    }
}
