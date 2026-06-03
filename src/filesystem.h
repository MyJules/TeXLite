
#ifndef FILESYSTEM_H
#define FILESYSTEM_H

#include <QObject>
#include <QString>
#include <QQuickItem>

class FileSystem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
    QML_ELEMENT
public:
    FileSystem(QObject *parent = nullptr);
    Q_INVOKABLE QString readFile(const QString& filePath);
    Q_INVOKABLE void writeToFile(const QString& filePath, const QString& content);
    Q_INVOKABLE void removeFile(const QString& filePath);
    Q_INVOKABLE void newFile(const QString& filePath);
    Q_INVOKABLE void clearTempFolder();
    Q_INVOKABLE QString getFileDir(const QString& filePath);
    Q_INVOKABLE void copyFile(const QString& from, const QString& to);
    Q_INVOKABLE QString createExampleProject(const QString& exampleId, const QString& targetDir);

    QString lastError() const;

signals:
    void lastErrorChanged();

private:
    void setLastError(const QString& error);

    QString m_lastError;
};

#endif // FILESYSTEM_H
