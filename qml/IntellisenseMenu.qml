import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Controls.Material

Popup {
    id: root
    focus: true
    width: 300
    height: 200
    modal: false

    signal intelisenceActivated
    signal keywordSelected(string keyword)

    onClosed: listView.currentIndex = 0

    Shortcut {
        sequence: "Ctrl+Space"
        onActivated: {
            intelisenceActivated()
        }
    }

    Shortcut {
        sequence: "Space"
        onActivated: {
            keywordSelected(listView.currentItem.text)
        }
    }

    ListView {
        id: listView
        spacing: 5
        focus: true
        anchors.fill: parent
        keyNavigationEnabled: true
        keyNavigationWraps: true

        Keys.onPressed: function (event) {
            //Qt.Key_Enter
            if (event.key === 16777220) {
                keywordSelected(listView.currentItem.text)
            }
        }

        Component {
            id: highlightDelegate
            Rectangle {
                color: "#1a75ff"
                radius: 4
            }
        }

        Component {
            id: delegate

            Text {
                text: keyword
                font.pointSize: 10
                color: "white"
                width: listView.width

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    onClicked: {
                        listView.currentIndex = index
                        keywordSelected(listView.currentItem.text)
                    }
                }
            }
        }

        model: LatexListModel {}
        delegate: delegate
        highlight: highlightDelegate
        highlightMoveDuration: 0
        highlightResizeDuration: 0
    }
}
