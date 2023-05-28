
#include "texengine.h"

#include <QProcess>
#include <QFile>
#include <QDebug>

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
    bool isFileExists = QFile::exists(m_texEngineArguments.first());
    qDebug() << m_texEngineArguments.first();
    if(isFileExists)
    {
        QProcess engineProcess;
        qDebug() << "Execute";
        engineProcess.start(m_texEngineCommand, m_texEngineArguments);
        qDebug() << m_texEngineCommand << m_texEngineArguments;
        engineProcess.waitForFinished(-1);
    }
}
