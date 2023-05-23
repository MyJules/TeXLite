import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import Qt.labs.folderlistmodel 2.15
import QtQuick.Dialogs


ApplicationWindow {
    id: root
    visible: true

    title: "TeXLite"

    width: 1280
    height: 720

    minimumWidth: 800
    minimumHeight: 400

    Material.theme: Material.Dark
    Material.accent: Material.BlueGrey

    header: AppHeader{}

    footer: AppFooter{}

    SplitView {
        id: rowLayout
        clip: true
        anchors.fill: parent
        orientation: Qt.Horizontal

        FileSystem{}

        LatexTextEdit{}

        PDFView{}
     }
}
