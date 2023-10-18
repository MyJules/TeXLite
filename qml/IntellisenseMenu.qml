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

    onClosed: {
        listView.currentIndex = 0
        intelisenseDisactivated()
    }

    Shortcut {
        sequence: "Ctrl+Space"
        onActivated: {
            intelisenceActivated()
        }
    }

    Rectangle {
        anchors.fill: parent
        clip: true
        radius: 3
        color: "#242323"
        border.color: "#b5b5b5"

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
                    keywordSelected(listView.currentItem.text)
                }
                keyPreseed(event.key, event.text)
            }

            Component {
                id: highlightDelegate
                Rectangle {
                    color: "#7a7a7a77"
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
            }

            highlight: highlightDelegate
            highlightMoveDuration: 0
            highlightResizeDuration: 0
        }
    }
}
