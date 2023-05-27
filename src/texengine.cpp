
#include "texengine.h"

#include <QProcess>

TexEngine::TexEngine(QObject *parent)
    : QObject{parent}
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

Q_INVOKABLE void TexEngine::execute()
{
    QProcess engineProcess;
    engineProcess.start(m_texEngineCommand);
}
