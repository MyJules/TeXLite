#ifndef TEXENGINE_H
#define TEXENGINE_H

#include <QObject>
#include <QString>
#include <QQuickItem>
#include <QStringList>

class TexEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString texEngineCommand READ texEngineCommand WRITE setTexEngineCommand)
    Q_PROPERTY(QStringList texEngineArguments READ texEngineArguments WRITE setTexEngineArguments)
    QML_ELEMENT
public:
    explicit TexEngine(QObject *parent = nullptr);
    QString texEngineCommand();
    void setTexEngineCommand(const QString&);
    QStringList texEngineArguments();
    void setTexEngineArguments(const QStringList&);
    Q_INVOKABLE void execute();

private:
    QString m_texEngineCommand;
    QStringList m_texEngineArguments;
};

#endif // TEXENGINE_H
