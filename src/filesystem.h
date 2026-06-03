
#ifndef FILESYSTEM_H
#define FILESYSTEM_H

#include <QObject>
#include <QString>
#include <QQuickItem>
#include <QDateTime>

class QFileSystemWatcher;

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
    Q_INVOKABLE void watchFile(const QString& filePath);

    QString lastError() const;

signals:
    void lastErrorChanged();
    void watchedFileChanged(const QString& filePath);

private:
    void refreshWatchedFileState(bool emitChange);
    void onWatchedFileChanged(const QString& path);
    void onWatchedDirectoryChanged(const QString& path);
    void setLastError(const QString& error);

    QString m_lastError;
    QFileSystemWatcher *m_fileWatcher;
    QString m_watchedFilePath;
    QString m_watchedDirectoryPath;
    QDateTime m_watchedFileLastModified;
    bool m_ignoreNextWatchedChange;
};

#endif // FILESYSTEM_H
