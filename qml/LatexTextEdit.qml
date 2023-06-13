import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material
import com.file

Rectangle {
    id: latexTextRect
    color: "#292929"
    clip: true

    property alias text: latexTextArea.text

    ScrollView {
        id: latexTextAreaScrollView
        anchors.fill: parent
        clip: true

        TextArea {
            id: latexTextArea
            focus: true
            font.pointSize: 12
            wrapMode: TextEdit.Wrap
        }
    }
}
