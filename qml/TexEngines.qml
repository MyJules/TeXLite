import QtQuick
import com.tex

Item {

    property string processingFile: ""
    property string engineName: "pdflatex"
    property TexEngine currentEngine: pdfLatex

    TexEngine {
        id: pdfLatex
        currentFile: processingFile
        texEngineCommand: "pdflatex"
        texEngineArguments: ["-halt-on-error"]
    }

    TexEngine {
        id: pdfTex
        currentFile: processingFile
        texEngineCommand: "pdftex"
        texEngineArguments: ["-halt-on-error"]
    }

    onEngineNameChanged: {
        switch (engineName) {
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
