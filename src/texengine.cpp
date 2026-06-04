
#include "texengine.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QRegularExpression>
#include <QUrl>

namespace {
QString resolveSourcePath(const QString &baseFile, const QString &inputPath)
{
    const QString localInputPath = QUrl(inputPath).toLocalFile();
    const QString path = localInputPath.isEmpty() ? inputPath : localInputPath;

    if (QFileInfo(path).isAbsolute())
        return path;

    return QFileInfo(baseFile).dir().absoluteFilePath(path);
}
}

TexEngine::TexEngine(QObject *parent)
    : QObject{parent}
    , m_state(TexEngine::EngineState::Idle)
    , m_compilationProcess(nullptr)
{
}

TexEngine::~TexEngine()
{
    if(m_compilationProcess)
        delete m_compilationProcess;
}

QString TexEngine::texEngineCommand()
{
    return m_texEngineCommand;
}

void TexEngine::setTexEngineCommand(const QString& texEngineCommand)
{
    m_texEngineCommand = texEngineCommand;
}

QString TexEngine::currentFile()
{
    return m_currentFile;
}

void TexEngine::setCurrentFile(const QString &currentFile)
{
    m_currentFile = QUrl(currentFile).toLocalFile();
    emit currentFileChanged();
}

QStringList TexEngine::texEngineArguments()
{
    return m_texEngineArguments;
}

void TexEngine::setTexEngineArguments(const QStringList& texEngineArguments)
{
    m_texEngineArguments << texEngineArguments;
}

TexEngine::EngineState TexEngine::state()
{
    return m_state;
}

void TexEngine::setState(TexEngine::EngineState state)
{
    m_state = state;
    emit stateChanged();
}

void TexEngine::syncTeXToSource(const QString &pdfFilePath, int page, qreal x, qreal y)
{
    const QString localPdfPath = QUrl(pdfFilePath).toLocalFile();
    if (localPdfPath.isEmpty() || !QFile::exists(localPdfPath))
        return;

    QProcess process;
    process.setProgram("synctex");
    process.setArguments({"edit",
                          "-o",
                          QString::number(page + 1)
                          + ":" + QString::number(x, 'f', 2)
                          + ":" + QString::number(y, 'f', 2)
                          + ":" + localPdfPath});
    process.start();

    if (!process.waitForFinished(3000) || process.exitStatus() != QProcess::NormalExit
            || process.exitCode() != 0) {
        return;
    }

        QString output = QString::fromUtf8(process.readAllStandardOutput())
            + QString::fromUtf8(process.readAllStandardError());
        output.replace("\r\n", "\n");
        output.replace('\r', '\n');

    static const QRegularExpression inputPattern(R"(^Input:(.+)$)",
                                                 QRegularExpression::MultilineOption);
    static const QRegularExpression linePattern(R"(^Line:(\d+)$)",
                                                QRegularExpression::MultilineOption);
    static const QRegularExpression columnPattern(R"(^Column:(\d+)$)",
                                                  QRegularExpression::MultilineOption);

    const QRegularExpressionMatch inputMatch = inputPattern.match(output);
    const QRegularExpressionMatch lineMatch = linePattern.match(output);
    const QRegularExpressionMatch columnMatch = columnPattern.match(output);

    if (!inputMatch.hasMatch() || !lineMatch.hasMatch())
        return;

    const QString sourcePath = resolveSourcePath(m_currentFile, inputMatch.captured(1).trimmed());
    const int line = qMax(1, lineMatch.captured(1).toInt());
    const int column = columnMatch.hasMatch() ? qMax(1, columnMatch.captured(1).toInt()) : 1;

    emit reverseSearchResolved(QUrl::fromLocalFile(sourcePath).toString(), line, column);
}

Q_INVOKABLE void TexEngine::compileToTempFolder(const QString fileName)
{
    bool isFileExists = QFile::exists(m_currentFile);
    TexEngine::EngineState currentState = state();

    if(!isFileExists || currentState == TexEngine::EngineState::Processing) return;

    if(m_compilationProcess){
        delete m_compilationProcess;
    }

    m_compilationProcess = new QProcess(this);
    QString workingFolder = QFileInfo(m_currentFile).dir().canonicalPath();
    QString tempFolder = QDir::current().filePath("temp");
    QDir().mkpath(tempFolder);

    m_compilationProcess->setWorkingDirectory(workingFolder);
    m_compilationProcess->setProgram(m_texEngineCommand);
    m_compilationProcess->setArguments(QStringList()
                                       << m_texEngineArguments
                                       << "-synctex=1"
                                       << ("-output-directory=" + tempFolder)
                                       << m_currentFile);
    m_compilationProcess->start();

    setState(TexEngine::EngineState::Processing);
    emit compilationStarted();

    connect(m_compilationProcess, &QProcess::finished, [this, fileName](int exitCode, QProcess::ExitStatus exitStatus){
        const QString tempFolder = QDir::current().filePath("temp");
        if(exitCode == 0)
        {
            const QString baseName = QFileInfo(m_currentFile).baseName();
            const QString compiledFilePath = QDir(tempFolder).filePath(baseName + ".pdf");
            const QString tempFilePath = QDir(tempFolder).filePath(fileName + ".pdf");
            const QString syncTexFilePath = QDir(tempFolder).filePath(baseName + ".synctex.gz");
            const QString tempSyncTexFilePath = QDir(tempFolder).filePath(fileName + ".synctex.gz");

            if (QFile::exists(tempFilePath))
                QFile::remove(tempFilePath);

            if (QFile::exists(tempSyncTexFilePath))
                QFile::remove(tempSyncTexFilePath);

            QFile::rename(compiledFilePath, tempFilePath);
            QFile::rename(syncTexFilePath, tempSyncTexFilePath);

            QDir tempDir(tempFolder);
            const QStringList artifacts = tempDir.entryList(QStringList()
                                                            << (baseName + ".aux")
                                                            << (baseName + ".log")
                                                            << (baseName + ".out")
                                                            << (baseName + ".toc")
                                                            << (baseName + ".nav")
                                                            << (baseName + ".snm")
                                                            << (baseName + ".fls")
                                                            << (baseName + ".fdb_latexmk"),
                                                            QDir::Files);
            for (const QString &artifact : artifacts)
                tempDir.remove(artifact);

            emit compilationFinished(tempFilePath);
        }else
        {
            setState(TexEngine::EngineState::Error);
            static QRegularExpression errorPattern(R"(.*:(\d+).*\n(.*)\n)");
            QString standardOutput = m_compilationProcess->readAllStandardOutput()
                    + m_compilationProcess->readAllStandardError();
            auto match = errorPattern.match(standardOutput);
            emit compilationError(match.captured());
            return;
        }
        setState(TexEngine::EngineState::Idle);
     });
}
