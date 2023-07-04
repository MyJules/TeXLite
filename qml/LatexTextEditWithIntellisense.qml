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
                break
            default:
                root.insertText(root.cursorPosition, text)
                break
            }
        }

        onIntelisenceActivated: {
            intellisense.x = root.cursorX - 15
            intellisense.y = root.cursorY + 10
            intellisense.focus = true
            intellisense.open()

            root.textCursorVisible = true
        }

        onKeywordSelected: function (keyword) {
            root.insertText(root.cursorPosition, keyword)
            intellisense.focus = false
            intellisense.close()
            latexTextEdit.textFocus = true
        }
    }
}
