import QtQuick

LatexTextEdit {
    id: root

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
        let farRight = x + intellisense.width
        let farBottom = y + intellisense.height

        if (farRight > root.width) {
            x += (root.width - farRight)
        }

        if (farBottom > root.height) {
            y += (root.height - farBottom)
            x += 5
        }

        intellisense.x = x - 15
        intellisense.y = y + 10
    }
}
