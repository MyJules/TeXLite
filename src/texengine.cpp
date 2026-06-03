
#include "texengine.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QRegularExpression>

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

            if (QFile::exists(tempFilePath))
                QFile::remove(tempFilePath);

            QFile::rename(compiledFilePath, tempFilePath);

            QDir tempDir(tempFolder);
            const QStringList artifacts = tempDir.entryList(QStringList()
                                                            << (baseName + ".aux")
                                                            << (baseName + ".log")
                                                            << (baseName + ".out")
                                                            << (baseName + ".toc")
                                                            << (baseName + ".nav")
                                                            << (baseName + ".snm")
                                                            << (baseName + ".fls")
                                                            << (baseName + ".fdb_latexmk")
                                                            << (baseName + ".synctex.gz"),
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
