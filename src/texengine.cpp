
#include "texengine.h"

#include <QDir>
#include <QFile>
#include <QDebug>
#include <QFileInfo>
#include <QtConcurrent>

TexEngine::TexEngine(QObject *parent)
    : QObject{parent}
    , m_state(EngineState::Idle)
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

EngineState TexEngine::state()
{
    return m_state;
}

void TexEngine::setState(EngineState state)
{
    m_state = state;
    emit stateChanged();
}

Q_INVOKABLE void TexEngine::compileToTempFolder(const QString fileName)
{
    bool isFileExists = QFile::exists(m_currentFile);
    EngineState currentState = state();

    if(!isFileExists || currentState == EngineState::Processing) return;


    auto engineFuture = QtConcurrent::run([this, fileName](){
        setState(EngineState::Processing);
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
            setState(EngineState::Error);
            emit compilationError(engineProcess.exitStatus());
        }
        setState(EngineState::Idle);
    });
}
