import QtQuick

LatexTextEdit {
    id: root

    onDCursorPositionChanged: {
        if (!intellisense.opened)
            return

        intellisense.x = root.cursorX
        intellisense.y = root.cursorY
    }

    IntellisenseMenu {
        id: intellisense

        onIntelisenceActivated: {
            intellisense.x = root.cursorX - 15
            intellisense.y = root.cursorY + 10
            intellisense.focus = true
            intellisense.open()
        }

        onKeywordSelected: function (keyword) {
            root.insertText(root.cursorPosition, keyword)
            intellisense.focus = false
            intellisense.close()
            latexTextEdit.textFocus = true
        }
    }
}
