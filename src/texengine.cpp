
#include "texengine.h"

#include <QDir>
#include <QFile>
#include <QDebug>
#include <QFileInfo>
#include <QtConcurrent>

TexEngine::TexEngine(QObject *parent)
    : QObject{parent}
    , m_state(TexEngine::EngineState::Idle)
{
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


    auto engineFuture = QtConcurrent::run([this, fileName](){
        setState(TexEngine::EngineState::Processing);
        emit compilationStarted();

        QString workingFolder = QFileInfo(m_currentFile).dir().canonicalPath();
        QProcess engineProcess;
        engineProcess.setWorkingDirectory(workingFolder);
        engineProcess.setProgram(m_texEngineCommand);
        engineProcess.setArguments(QStringList() << m_texEngineArguments << m_currentFile);
        engineProcess.start();
        engineProcess.waitForFinished(-1);

        if(engineProcess.exitCode() == 0)
        {
            QDir currentDir;
            QString tempFilePath = QDir::currentPath() + "/temp/" + fileName + ".pdf";
            bool renamed = currentDir.rename(workingFolder + "/" + QFileInfo(m_currentFile).baseName() + ".pdf" ,
                                             tempFilePath);
            emit compilationFinished(tempFilePath);
        }else
        {
            setState(TexEngine::EngineState::Error);
            QRegularExpression errorPattern(R"(.*:(\d+).*\n(.*)\n)");
            QString standardOutput = engineProcess.readAllStandardOutput();
            auto match = errorPattern.match(standardOutput);
            emit compilationError(match.captured());
            return;
        }
        setState(TexEngine::EngineState::Idle);
    });
}
