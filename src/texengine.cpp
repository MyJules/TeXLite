
#include "texengine.h"

#include <QFile>
#include <QDebug>
#include <QProcess>
#include <QDir>
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
    currentFilechanged();
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
    qDebug()<< "execute:   " << m_currentFile;

    if(!isFileExists || currentState != EngineState::Idle) return;

    std::thread task([this, &fileName](){
        qDebug()<< "Compile!!!! " << m_texEngineArguments << m_texEngineCommand ;
        setState(EngineState::Processing);
        QProcess engineProcess;
        engineProcess.start(m_texEngineCommand, QStringList() << m_currentFile << m_texEngineArguments);
        engineProcess.waitForFinished(-1);

        QDir currentDir;
        bool renamed = currentDir.rename(m_currentFile , "temp/" + fileName);
        setState(EngineState::Idle);
    });
    task.detach();
}
