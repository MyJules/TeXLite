import QtQuick
import QtQuick.Layouts

Item {
    id: root

    signal ddCursorPositionChanged

    property alias corsorLine: latexTextEditWithIntellisense.cursorLine
    property alias text: latexTextEditWithIntellisense.text

    //Properties forline count
    property int step: 1
    property real zeroMargin: -(latexTextEditWithIntellisense.scrolledLines)
    property real size: latexTextEditWithIntellisense.areaLineCount
    property real _ws: width / size
    property real _hs: height / size

    RowLayout {
        id: rowLayout
        anchors.fill: parent

        Canvas {
            id: lineCountCanvas
            Layout.preferredWidth: 25
            Layout.fillHeight: true

            onPaint: paintLineCount(getContext("2d"), height, width)
        }

        LatexTextEditWithIntellisense {
            id: latexTextEditWithIntellisense
            onDCursorPositionChanged: {
                ddCursorPositionChanged()
                lineCountCanvas.requestPaint()
            }
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    function paintLineCount(ctx, height, width) {
        ctx.clearRect(0, 0, width, height)
        if (step <= 0)
            return

        ctx.strokeStyle = Qt.rgba(1, 1, 1, 1)
        ctx.lineWidth = 1
        ctx.beginPath()

        let firstLine = -Math.floor(zeroMargin)
        for (var y = 0; y < size; y += step) {
            let yLinePosition = (y + (zeroMargin % step)) * _hs
            let lineValue = Math.floor(firstLine + ((y + (zeroMargin % step))))

            //            if (lineValue <= 0)
            //                continue
            ctx.moveTo(0, yLinePosition)
            ctx.text(lineValue, ctx.measureText(lineValue).width / 4,
                     yLinePosition)
        }

        ctx.stroke()
    }
}
