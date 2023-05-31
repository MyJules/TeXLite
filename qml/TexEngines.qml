import QtQuick
import com.tex

Item {

    property string processingFile: ""
    property string texEngineCommand: "pdflatex"
    property TexEngine currentEngine: pdfLatex

    TexEngine {
        id: pdfLatex
        currentFile: processingFile
        texEngineCommand: "pdflatex"
        texEngineArguments: []
    }

    TexEngine {
        id: pdfTex
        currentFile: processingFile
        texEngineCommand: "pdftex"
        texEngineArguments: []
    }

    onProcessingFileChanged: {
        switch (texEngineCommand) {
        case pdfLatex.texEngineCommand:
            currentEngine = pdfLatex
            break
        case pdfTex.texEngineCommand:
            currentEngine = pdfTex
            break
        default:
            break
        }
    }
}
