import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.1

ApplicationWindow {
    visible: true

    title: "TeXLite"

    width: 800
    height: 500

    minimumWidth: 600
    minimumHeight: 400

    Material.theme: Material.Dark
    Material.accent: Material.Red

    RowLayout{
        id: rowLayout
        clip: true
        anchors.fill: parent

        Rectangle {
            id: menuBar
            color: Material.color(Material.Indigo)
            width: 60
            Layout.fillHeight: true
        }

        Rectangle {
            id: latexText
            color: Material.color(Material.Red)
            width: 250
            Layout.fillHeight: true
        }

        Rectangle {
            id: latexPDF
            color: Material.color(Material.Blue)
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
     }
}
