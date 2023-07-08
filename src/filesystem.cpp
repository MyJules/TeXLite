
#include "filesystem.h"

#include <QDir>
#include <QFile>

FileSystem::FileSystem(QObject *parent)
{

}

Q_INVOKABLE QString FileSystem::readFile(const QString &filePath)
{
    QString path = QUrl(filePath).toLocalFile();

    QFile file(path);
    if (!file.open(QFile::ReadOnly | QFile::Text))
        return "No file found";

    QTextStream in(&file);
    return in.readAll();
}

Q_INVOKABLE void FileSystem::writeToFile(const QString &filePath, const QString &content)
{
    QString path = QUrl(filePath).toLocalFile();

    QFile file(path);
    if (file.open(QIODevice::ReadWrite | QFile::Truncate)) {
        QTextStream out(&file);
        out << content;
    }
}

Q_INVOKABLE void FileSystem::removeFile(const QString &filePath)
{
    QString path = QUrl(filePath).toLocalFile();
    QFile file(path);
}

Q_INVOKABLE void FileSystem::newFile(const QString &filePath)
{
    QString path = QUrl(filePath).toLocalFile();

    QFile file(path);
    file.open(QIODevice::WriteOnly);
    file.close();
    qDebug() << path;
}

Q_INVOKABLE void FileSystem::clearTempFolder()
{
    QDir tempDir(QDir::currentPath() + "/temp");
    tempDir.removeRecursively();
    tempDir.mkdir(QDir::currentPath() + "/temp");
}

Q_INVOKABLE QString FileSystem::getFileDir(const QString &filePath)
{
    QFileInfo info(filePath);
    return info.dir().path();
}

Q_INVOKABLE void FileSystem::copyFile(const QString &from, const QString &to)
{
    if (QFile::exists(QUrl(to).toLocalFile()))
    {
        QFile::remove(QUrl(to).toLocalFile());
    }

    QFile::copy(QUrl(from).toLocalFile(), QUrl(to).toLocalFile());
}
