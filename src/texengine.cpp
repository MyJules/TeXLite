
#include "texengine.h"

#include <QDir>
#include <QFile>
#include <QDebug>
#include <QProcess>
#include <QFileInfo>

#include <thread>
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

Q_INVOKABLE void TexEngine::compileToTempFolder(const QString& fileName)
{
    bool isFileExists = QFile::exists(m_currentFile);
    EngineState currentState = state();

    if(!isFileExists || currentState != EngineState::Idle) return;

    std::thread task([this, &fileName](){
        setState(EngineState::Processing);
        emit compilationStarted();

        QProcess engineProcess;
        engineProcess.start(m_texEngineCommand, QStringList() << m_texEngineArguments << m_currentFile);
        engineProcess.waitForFinished(-1);

        if(engineProcess.exitStatus() == 0)
        {
            QDir currentDir;
            const QString tempFilePath = "temp/" + fileName + ".pdf";
            bool renamed = currentDir.rename(QFileInfo(m_currentFile).baseName() + ".pdf" , tempFilePath);
            emit compilationFinished(tempFilePath);
        }
        setState(EngineState::Idle);

    });
    task.detach();
}
