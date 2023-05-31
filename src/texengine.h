#ifndef TEXENGINE_H
#define TEXENGINE_H

#include <QObject>
#include <QString>
#include <QQuickItem>
#include <QStringList>

enum class EngineState
{
    Idle,
    Processing
};

class TexEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString texEngineCommand READ texEngineCommand WRITE setTexEngineCommand)
    Q_PROPERTY(QString currentFile READ currentFile WRITE setCurrentFile NOTIFY currentFilechanged)
    Q_PROPERTY(QStringList texEngineArguments READ texEngineArguments WRITE setTexEngineArguments)
    Q_PROPERTY(EngineState state READ state WRITE setState NOTIFY stateChanged)
    QML_ELEMENT
public:
    explicit TexEngine(QObject *parent = nullptr);
    QString texEngineCommand();
    void setTexEngineCommand(const QString&);
    QString currentFile();
    void setCurrentFile(const QString&);
    QStringList texEngineArguments();
    void setTexEngineArguments(const QStringList&);
    EngineState state();
    void setState(EngineState);
    Q_INVOKABLE void execute();

signals:
    void stateChanged();
    void currentFilechanged();

private:
    QString m_texEngineCommand;
    QString m_currentFile;
    QStringList m_texEngineArguments;
    EngineState m_state;
};

#endif // TEXENGINE_H
