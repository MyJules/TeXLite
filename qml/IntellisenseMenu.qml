import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Controls.Material

Popup {
    id: root
    clip: true
    modal: false
    width: 300
    height: 200
    background: Item {}

    signal intelisenceActivated
    signal intelisenseDisactivated
    signal keywordSelected(string keyword)
    signal keyPreseed(int key, string text)

    property string searchWord

    function setNoSuggestionState() {
        root.width = 300
        root.height = 45
        noSuggestionText.visible = true
    }

    function setSuggestionState() {
        root.width = 300
        root.height = 200
        noSuggestionText.visible = false
    }

    function checkSuggestionState() {
        if (listView.count == 0) {
            setNoSuggestionState()
        } else {
            setSuggestionState()
        }
    }

    onOpened: {
        setSuggestionState()
        checkSuggestionState()
    }

    onClosed: {
        listView.currentIndex = 0
        intelisenseDisactivated()
        noSuggestionText.visible = false
    }

    Shortcut {
        sequence: "Ctrl+Space"
        onActivated: {
            intelisenceActivated()
        }
    }

    Rectangle {
        id: inteliRect
        anchors.fill: parent
        clip: true
        radius: 3
        color: "#242323"
        border.color: "#363945"

        Text {
            id: noSuggestionText
            text: "No suggestions"
            visible: false
            color: "white"
            font.pointSize: 10
            anchors.left: inteliRect.left
            anchors.leftMargin: 4
        }

        ListView {
            id: listView
            spacing: 4
            focus: true
            anchors.fill: parent
            anchors.margins: 4
            keyNavigationEnabled: true
            keyNavigationWraps: true

            Keys.onPressed: function (event) {
                //Qt.Key_Enter
                if (event.key === 16777220) {
                    if (listView.currentItem) {
                        keywordSelected(listView.currentItem.text)
                    } else {
                        root.close()
                    }
                }
                keyPreseed(event.key, event.text)
            }

            Component {
                id: highlightDelegate
                Rectangle {
                    color: "#363945"
                    radius: 3
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

            model: FilterDelegateModel {
                model: LatexListModel {}
                filter: search ? model => model.keyword.toLowerCase().indexOf(
                                     search) !== -1 : null
                property string search: searchWord.toLowerCase()
                onSearchChanged: Qt.callLater(update)
                delegate: delegate
                onUpdated: {
                    checkSuggestionState()
                }
            }

            highlight: highlightDelegate
            highlightMoveDuration: 0
            highlightResizeDuration: 0
        }
    }
}
