import QtQuick
import com.tex

Item {
    signal dCompilationFinished(string filePath)
    signal dCompilationStarted
    signal dCompilationError(string error)
    signal dStateChanged

    property string processingFile: ""
    property string engineName: "pdflatex"
    property TexEngine currentEngine: pdfLatex
    property int state: currentEngine.state

    TexEngine {
        id: pdfLatex
        currentFile: processingFile
        texEngineCommand: "pdflatex"
        texEngineArguments: ["-halt-on-error", "-file-line-error", "-interaction=nonstopmode"]

        onCompilationFinished: filePath => dCompilationFinished(filePath)
        onCompilationStarted: dCompilationStarted()
        onCompilationError: error => dCompilationError(error)
        onStateChanged: dStateChanged()
    }

    onEngineNameChanged: {
        switch (engineName) {
        case pdfLatex.texEngineCommand:
            currentEngine = pdfLatex
            break
        default:
            break
        }
    }
}
