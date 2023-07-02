import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Controls.Material

Popup {
    id: root

    signal intelisenceActivated

    function popUp() {
        root.open()
    }

    Shortcut {
        sequence: "Ctrl+Space"
        onActivated: {
            intelisenceActivated
        }
    }

    width: 300
    height: 200
    modal: false
    focus: true
}
