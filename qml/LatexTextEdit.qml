import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material
import com.file

Rectangle {
    id: latexTextRect
    color: "#292929"
    clip: true

    property string currentFilePath: ""

    ScrollView {
        id: latexTextAreaScrollView
        anchors.fill: parent

        TextArea {
            id: latexTextArea
            focus: true
            wrapMode: TextEdit.Wrap
            font.pointSize: 12
        }
    }

    onCurrentFilePathChanged: {
        console.log(currentFilePath)
        latexTextArea.text = fileSystem.readFile(currentFilePath)
    }

    FileSystem {
        id: fileSystem
    }
}
