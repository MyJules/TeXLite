import QtQuick

LatexTextEdit {
    id: root

    onDCursorPositionChanged: {
        if (!intellisense.opened)
            return

        intellisense.x = root.cursorX - 15
        intellisense.y = root.cursorY + 10
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
            intellisense.searchWord = ""
            intellisense.x = root.cursorX - 15
            intellisense.y = root.cursorY + 10
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
}
