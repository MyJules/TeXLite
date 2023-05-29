
#include "texengine.h"

#include <QFile>
#include <QDebug>
#include <QProcess>
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

Q_INVOKABLE void TexEngine::execute()
{
    bool isFileExists = QFile::exists(m_texEngineArguments.first());
    EngineState currentState = state();

    if(!isFileExists || currentState != EngineState::Idle) return;

    std::thread task([this](){
        setState(EngineState::Processing);
        QProcess engineProcess;
        engineProcess.start(m_texEngineCommand, m_texEngineArguments);
        engineProcess.waitForFinished(-1);
        setState(EngineState::Idle);
    });
    task.detach();
}
